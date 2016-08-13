require 'test_helper'

class CastlingTest < ActionDispatch::IntegrationTest
  
  def setup
    @player_1 = players(:player_1)
    @player_2 = players(:player_2)
    
    log_in_as @player_1, { password: '123greetings' }
    log_in_as @player_2, { password: '123greetings' }
    
    post_via_redirect games_path, game: { white_player_id: @player_1.id }
    
    @game = assigns(:game)
    
    @game.update_attribute(:black_player_id, @player_2.id)

    @game.pieces.each { |piece| piece.update_attribute(:captured?, true) }

    @king_w = King.create(game: @game, color: 'white', x_coordinate: 5, y_coordinate: 1, player_id: @player_1.id)
    @king_b = King.create(game: @game, color: 'black', x_coordinate: 5, y_coordinate: 8, player_id: @player_2.id)

    @rook_1w = Rook.create(game: @game, color: 'white', x_coordinate: 1, y_coordinate: 1, player_id: @player_1.id)
    @rook_2w = Rook.create(game: @game, color: 'white', x_coordinate: 8, y_coordinate: 1, player_id: @player_1.id)

    @rook_1b = Rook.create(game: @game, color: 'black', x_coordinate: 1, y_coordinate: 8, player_id: @player_2.id)
    @rook_2b = Rook.create(game: @game, color: 'black', x_coordinate: 8, y_coordinate: 8, player_id: @player_2.id)
  end

  test 'should castle king-side for white king' do
    create_castle @king_w, @rook_2w, 7, 1

    validate_castle 'King', 7, 6, @king_w, @rook_2w
  end

  test 'should castle queen-side for white king' do
    create_castle @king_w, @rook_1w, 3, 1

    validate_castle 'Queen', 3, 4, @king_w, @rook_1w
  end

  private

    def create_castle(king, rook, x, y)
      put game_piece_path(game_id: @game, id: king, piece: { id: king, x_coordinate: x, y_coordinate: y })
      
      king.reload
      rook.reload
    end
  
    def validate_castle(type, kx, rx, king, rook)
      assert_equal kx, king.x_coordinate, "#{type}-side castle for #{king.color} king failed? (king move)"
      assert_equal rx, rook.x_coordinate, "#{type}-side castle for #{king.color} king failed? (rook auto-move)"
    end
    
end
