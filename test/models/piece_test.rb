require 'test_helper'

class PieceTest < ActiveSupport::TestCase

  def setup
    @game = games(:one)

    @A6 = Bishop.create(game: @game, color: 'white', x_coordinate: 1, y_coordinate: 6)
    @C4 = Pawn.create(game: @game, color: 'black', x_coordinate: 3, y_coordinate: 4)
    @F1 = Bishop.create(game: @game, color: 'black', x_coordinate: 6, y_coordinate: 1)
    @E2 = Pawn.create(game: @game, color: 'black', x_coordinate: 5, y_coordinate: 2)
    @A1 = Rook.create(game: @game, color: 'black', x_coordinate: 1, y_coordinate: 1)
    @E5 = Pawn.create(game: @game, color: 'black', x_coordinate: 5, y_coordinate: 5)
    @A8 = Rook.create(game: @game, color: 'white', x_coordinate: 1, y_coordinate: 8)
    @A8 = Rook.create(game: @game, color: 'white', x_coordinate: 1, y_coordinate: 8)
    @A2 = Pawn.create(game: @game, color: 'black', x_coordinate: 1, y_coordinate: 2)
    @D4 = Knight.create(game: @game, color: 'white', x_coordinate: 4, y_coordinate: 4)
    @E7 = Queen.create(game: @game, color: 'white', x_coordinate: 5, y_coordinate: 7)
    @F6 = Rook.create(game: @game, color: 'white', x_coordinate: 6, y_coordinate: 6)
  end

  test "is_obstructed? - should correctly determine if a piece is obstructed" do
  # A6 -> C4 => false
    assert_not @A6.is_obstructed?(3, 4), "Should be false"
  # F1 -> D3 => true
    assert @F1.is_obstructed?(4, 3), "Should be true"
  # A1 -> A4 => true
    assert @A1.is_obstructed?(1, 4), "Should be true"
  # E7 -> C6 => Raise error # Invalid move: not diagnal, horizontal, or vertical.
    assert_raises(ArgumentError) { @E7.is_obstructed?(3, 6) }
  # D4 -> B5 => false
    assert_not @D4.is_obstructed?(2, 5), "Should be false"
  # A8 -> A6 => false
    assert_not @A8.is_obstructed?(1, 6), "Should be false"
  # A8 -> C8 => false
    assert_not @A8.is_obstructed?(3, 8), "Should be false"
  end

  test 'should find positions between two points in vertical movement' do
    assert_equal([[1, 2], [1, 3]], @A1.pathway_array(1, 4))
  end

  test 'should find positions between two points in horizontal movement' do
    assert_equal([[2, 8]], @A8.pathway_array(3, 8))
  end

  test 'should find positions between two points in diagonal movement' do
    assert_equal([[5, 2]], @F1.pathway_array(4, 3))
  end
  
  test "capturing of pieces" do
  # Test white Knight capturing a black Pawn
    assert @D4.move_to!(5, 2), "White knight can't capture black pawn?"
    assert_not Piece.exists?(@E2), "Black pawn not captured?"

  # Test black pawn capturing a white Rook
    assert @E5.move_to!(6, 6), "Black Pawn can't capture white rook?"
    assert_not Piece.exists?(@F6), "White rook not captured?"
  end

end
