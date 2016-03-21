require 'test_helper'

class PawnPromotionTest < ActionDispatch::IntegrationTest
  
  def setup
    @game = games(:one)
    
    @B1 = Pawn.create(game: @game, color: 'white', x_coordinate: 2, y_coordinate: 1)
    @G8 = Pawn.create(game: @game, color: 'black', x_coordinate: 7, y_coordinate: 8)
  end

  test "should execute valid Queen promotion for white pawn" do
    validate_promotion @B1, "Queen", 1, 1, "white"
  end

  test "should execute valid Knight promotion for white pawn" do
    validate_promotion @B1, "Knight", 1, 1, "white"
  end

  test "should execute valid Rook promotion for white pawn" do
    validate_promotion @B1, "Rook", 1, 1, "white"
  end

  test "should execute valid Bishop promotion for white pawn" do
    validate_promotion @B1, "Bishop", 1, 1, "white"
  end

  test "should execute valid Queen promotion for black pawn" do
    validate_promotion @G8, "Queen", 8, 8, "black"
  end
  
  test "should execute valid Knight promotion for black pawn" do
    validate_promotion @G8, "Knight", 8, 8, "black"
  end
  
  test "should execute valid Rook promotion for black pawn" do
    validate_promotion @G8, "Rook", 8, 8, "black"
  end
  
  test "should execute valid Bishop promotion for black pawn" do
    validate_promotion @G8, "Bishop", 8, 8, "black"
  end

  private
  
    def validate_promotion(piece, promotion, x, y, color)
      put game_piece_path(game_id: @game, id: piece, piece: { id: piece, x_coordinate: x, y_coordinate: y, type: promotion })
      promoted_piece = Game.find(@game.id).pieces.where(color: color).last
      assert_instance_of promotion.constantize, promoted_piece, "Pawn not promoted to #{promotion}?"
      assert_equal promotion, promoted_piece.type, "Pawn not promoted to #{promotion}?"
      assert_equal color, promoted_piece.color, "Piece did not remain #{color}?"
    end

end
