require 'test_helper'

class CastlingTest < ActionDispatch::IntegrationTest

  def setup
    @player_1 = players(:player_1)
    @player_2 = players(:player_2)
    
    log_in_as @player_1, { password: '123greetings' }
    
    post_via_redirect games_path, game: { white_player_id: @player_1.id }
    
    @game = assigns(:game)
    
    @game.update_attribute(:black_player_id, @player_2.id)

    pieces_to_remove = @game.pieces.where.not(type: ['King', 'Rook'])
    
    pieces_to_remove.each { |piece| piece.update_attribute(:captured?, true) }

    @king_w = @game.pieces.where(type: 'King', color: 'white').last
    @king_b = @game.pieces.where(type: 'King', color: 'black').last
    
    @rook_1w = @game.pieces.where(type: 'Rook', color: 'white', x_coordinate: 8, y_coordinate: 1).last
    @rook_2w = @game.pieces.where(type: 'Rook', color: 'white', x_coordinate: 8, y_coordinate: 8).last

    @rook_1b = @game.pieces.where(type: 'Rook', color: 'black', x_coordinate: 1, y_coordinate: 1).last
    @rook_2b = @game.pieces.where(type: 'Rook', color: 'black', x_coordinate: 1, y_coordinate: 8).last
    
    @game.pieces.where(type: ['King', 'Rook'], color: 'black').each { |piece| piece.update_attribute(:player_id, @player_1.id) }
  end

  test "should castle king-side for white king" do
    create_castle @king_w, @rook_2w, 8, 7
    
    validate_castle "King", 7, 6, @king_w, @rook_2w
  end

  test "should castle queen-side for white king" do
    create_castle @king_w, @rook_1w, 8, 3
    
    validate_castle "Queen", 3, 4, @king_w, @rook_1w
  end

  test "should castle king-side for black king" do
    create_castle @king_b, @rook_2b, 1, 7
    
    validate_castle "King", 7, 6, @king_b, @rook_2b
  end

  test "should castle queen-side for black king" do
    create_castle @king_b, @rook_1b, 1, 3
    
    validate_castle "Queen", 3, 4, @king_b, @rook_1b
  end

  private
  
    def create_castle(king, rook, x, y)
      put game_piece_path(game_id: @game, id: king, piece: { id: king, x_coordinate: x, y_coordinate: y })
      
      king.reload
      rook.reload
    end
    
    def validate_castle(type, ky, ry, king, rook)
      assert_equal ky, king.y_coordinate, "#{type}-side castle for #{king.color} king failed? (king move)"
      assert_equal ry, rook.y_coordinate, "#{type}-side castle for #{king.color} king failed? (rook auto-move)"
    end

end
