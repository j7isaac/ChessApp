require 'test_helper'

class PieceTest < ActiveSupport::TestCase

  def setup
    @game = games(:one)
    @player_1 = players(:player_1)
    @player_2 = players(:player_2)
    
    @game.turn = @player_1.id

    @A6 = Bishop.create(game: @game, color: 'white', x_coordinate: 1, y_coordinate: 6, player_id: @player_1.id)
    @C4 = Pawn.create(game: @game, color: 'black', x_coordinate: 3, y_coordinate: 4, player_id: @player_2.id)
    @F1 = Bishop.create(game: @game, color: 'black', x_coordinate: 6, y_coordinate: 1, player_id: @player_2.id)
    @E2 = Pawn.create(game: @game, color: 'black', x_coordinate: 5, y_coordinate: 2, player_id: @player_2.id)
    @A1 = Rook.create(game: @game, color: 'black', x_coordinate: 1, y_coordinate: 1, player_id: @player_2.id)
    @E5 = Pawn.create(game: @game, color: 'black', x_coordinate: 5, y_coordinate: 5, player_id: @player_2.id)
    @A8 = Rook.create(game: @game, color: 'white', x_coordinate: 1, y_coordinate: 8, player_id: @player_1.id)
    @A8 = Rook.create(game: @game, color: 'white', x_coordinate: 1, y_coordinate: 8, player_id: @player_1.id)
    @A2 = Pawn.create(game: @game, color: 'black', x_coordinate: 1, y_coordinate: 2, player_id: @player_2.id)
    @D4 = Knight.create(game: @game, color: 'white', x_coordinate: 4, y_coordinate: 4, player_id: @player_1.id)
    @E7 = Queen.create(game: @game, color: 'white', x_coordinate: 5, y_coordinate: 7, player_id: @player_1.id)
    @F6 = Rook.create(game: @game, color: 'white', x_coordinate: 6, y_coordinate: 6, player_id: @player_1.id)
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

  test "should capture black piece" do
  # Test white Knight capturing a black Pawn
    assert @D4.move_to!(5, 2), "White knight can't capture black pawn?"
  # Reload the Pawn object to refresh its captured attribute
    @E2.reload
    assert @E2.captured?, "Black pawn not captured?"
  end

  test "should capture white piece" do
    @game.turn = @player_2.id

  # Test black Pawn capturing a white Rook
    assert @E5.move_to!(6, 6), "Black pawn can't capture white rook?"
  # Reload the Rook object to refresh its captured attribute
    @F6.reload
    assert @F6.captured?, "White rook not captured?"
  end

end
