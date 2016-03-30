require 'test_helper'

class PieceTest < ActiveSupport::TestCase

  def setup
    @game = games(:one)

    @A1 = Rook.create(game: @game, color: 'black', x_coordinate: 1, y_coordinate: 1)
    @A2 = Pawn.create(game: @game, color: 'black', x_coordinate: 1, y_coordinate: 2)
    @A6 = Bishop.create(game: @game, color: 'white', x_coordinate: 1, y_coordinate: 6)
    @A8 = Rook.create(game: @game, color: 'white', x_coordinate: 1, y_coordinate: 8)
    
    @C4 = Pawn.create(game: @game, color: 'black', x_coordinate: 3, y_coordinate: 4)
    @C5 = King.create(game: @game, color: 'black', x_coordinate: 3, y_coordinate: 5)
    @C6 = Pawn.create(game: @game, color: 'black', x_coordinate: 3, y_coordinate: 6)
    @C7 = Knight.create(game: @game, color: 'black', x_coordinate: 3, y_coordinate: 7)
    
    @D4 = Knight.create(game: @game, color: 'white', x_coordinate: 4, y_coordinate: 4)

    @E2 = Pawn.create(game: @game, color: 'black', x_coordinate: 5, y_coordinate: 2)
    @E5 = Pawn.create(game: @game, color: 'black', x_coordinate: 5, y_coordinate: 5)
    @E6 = Rook.create(game: @game, color: 'black', x_coordinate: 5, y_coordinate: 6)
    @E7 = Queen.create(game: @game, color: 'white', x_coordinate: 5, y_coordinate: 7)
    
    @F1 = Bishop.create(game: @game, color: 'black', x_coordinate: 6, y_coordinate: 1)
    @F6 = Rook.create(game: @game, color: 'white', x_coordinate: 6, y_coordinate: 6)
    
    @H8 = King.create(game: @game, color: 'white', x_coordinate: 8, y_coordinate: 8)
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
    assert_equal [[1, 2], [1, 3]], @A1.pathway_array(1, 4)
  end

  test 'should find positions between two points in horizontal movement' do
    assert_equal [[2, 8]], @A8.pathway_array(3, 8)
  end

  test 'should find positions between two points in diagonal movement' do
    assert_equal [[5, 2]], @F1.pathway_array(4, 3)
  end
  
  test "capturing of pieces" do
  # Test white Knight capturing a black Pawn
    assert @D4.move_to!(5, 2), "White knight can't capture black pawn?"
  # Reload the Pawn object to refresh its captured attribute
    @E2.reload
    assert @E2.captured?, "Black pawn not captured?"

  # Test black Pawn capturing a white Rook
    assert @E5.move_to!(6, 6), "Black pawn can't capture white rook?"
  # Reload the Rook object to refresh its captured attribute
    @F6.reload
    assert @F6.captured?, "White rook not captured?"
  end

  test "should cause check" do
  # Test white Rook putting black King in check
    @F6.move_to! 6, 5
    assert @F6.game.in_check?(@F6.color), "Game not in check?"
  end

  test "should prevent entering check" do
  # Test black King avoiding moving into check
    assert_not @C5.move_to! 3, 6
    assert_not @C5.game.in_check?(@C5.color), "Black King entered check?"
  end

  test "should eliminate check" do
  # Test that a black Rook rescues black King from being in check
    @C5.move_to! 4, 5
    @F6.move_to! 6, 5
    assert @F6.game.in_check?(@F6.color), "Game not in check?"

    @E6.move_to! 5, 5
    assert_not @E6.game.in_check?(@E6.color), "Game still in check?"
  end

end
