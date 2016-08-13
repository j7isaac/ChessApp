require 'test_helper'

class PawnPromotionTest < ActionDispatch::IntegrationTest
  
  def setup
    @player_1 = players(:player_1)
    @player_2 = players(:player_2)
    
    log_in_as @player_1, { password: '123greetings' }
    log_in_as @player_2, { password: '123greetings' }
    
    post_via_redirect games_path, game: { white_player_id: @player_1.id }
    
    @game = assigns(:game)
    
    @game.update_attribute(:black_player_id, @player_2.id)

    @game.pieces.each { |piece| piece.update_attribute(:captured?, true) }
    
    @e8 = King.create(game: @game, color: 'white', x_coordinate: 8, y_coordinate: 5, player_id: @player_1.id)
    @e1 = King.create(game: @game, color: 'black', x_coordinate: 1, y_coordinate: 5, player_id: @player_2.id)
    
    @g7 = Pawn.create(game: @game, color: 'white', x_coordinate: 7, y_coordinate: 7, player_id: @player_1.id)
    @b2 = Pawn.create(game: @game, color: 'black', x_coordinate: 2, y_coordinate: 2, player_id: @player_2.id)
  end

  test 'should execute valid Queen promotion for white pawn' do
    validate_promotion @g7, 7, 8, 'Queen', 'white'
  end

  test 'should execute valid Knight promotion for white pawn' do
    validate_promotion @g7, 7, 8, 'Knight', 'white'
  end

  test 'should execute valid Rook promotion for white pawn' do
    validate_promotion @g7, 7, 8, 'Rook', 'white'
  end

  test 'should execute valid Bishop promotion for white pawn' do
    validate_promotion @g7, 7, 8, 'Bishop', 'white'
  end

  private

    def validate_promotion(piece, x, y, promotion, color)
      put game_piece_path(game_id: @game, id: piece, piece: { id: piece, x_coordinate: x, y_coordinate: y, type: promotion })
      promoted_piece = Game.find(@game.id).pieces.where(color: color).last
      assert_instance_of promotion.constantize, promoted_piece, "Pawn not promoted to #{promotion}?"
      assert_equal promotion, promoted_piece.type, "Pawn not promoted to #{promotion}?"
      assert_equal color, promoted_piece.color, "Piece did not remain #{color}?"
    end
    
end
