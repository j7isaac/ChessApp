require 'test_helper'

class PieceTest < ActiveSupport::TestCase
  
  def setup
    @game = games(:one)

    @player_1 = players(:player_1)
    @player_2 = players(:player_2)
    
    @game.white_player_id = @player_1.id
    @game.black_player_id = @player_2.id

    @game.turn = @player_1.id
    
    @a1 = Rook.create(game: @game, color: 'black', x_coordinate: 1, y_coordinate: 1)
    @a2 = Pawn.create(game: @game, color: 'black', x_coordinate: 1, y_coordinate: 2)
    @a6 = Bishop.create(game: @game, color: 'white', x_coordinate: 1, y_coordinate: 6)
    @a8 = Rook.create(game: @game, color: 'white', x_coordinate: 1, y_coordinate: 8)

    @c4 = Pawn.create(game: @game, color: 'black', x_coordinate: 3, y_coordinate: 4)
    @c5 = King.create(game: @game, color: 'black', x_coordinate: 3, y_coordinate: 5)
    @c6 = Pawn.create(game: @game, color: 'black', x_coordinate: 3, y_coordinate: 6)
    @c7 = Knight.create(game: @game, color: 'black', x_coordinate: 3, y_coordinate: 7, player_id: @player_2.id)

    @d4 = Knight.create(game: @game, color: 'white', x_coordinate: 4, y_coordinate: 4, player_id: @player_1.id)

    @e2 = Pawn.create(game: @game, color: 'black', x_coordinate: 5, y_coordinate: 2)
    @e5 = Pawn.create(game: @game, color: 'black', x_coordinate: 5, y_coordinate: 5, player_id: @player_2.id)
    @e6 = Rook.create(game: @game, color: 'black', x_coordinate: 5, y_coordinate: 6)
    @e7 = Queen.create(game: @game, color: 'white', x_coordinate: 5, y_coordinate: 7)

    @f1 = Bishop.create(game: @game, color: 'black', x_coordinate: 6, y_coordinate: 1)
    @f6 = Rook.create(game: @game, color: 'white', x_coordinate: 6, y_coordinate: 6)

    @h8 = King.create(game: @game, color: 'white', x_coordinate: 8, y_coordinate: 8)
  end

  test 'is_obstructed? - should correctly determine if a piece is obstructed' do
    # A6 -> C4 => false
    assert_not @a6.is_obstructed?(3, 4), 'Should be false'
    # F1 -> D3 => true
    assert @f1.is_obstructed?(4, 3), 'Should be true'
    # A1 -> A4 => true
    assert @a1.is_obstructed?(1, 4), 'Should be true'
    # D4 -> B5 => false
    assert_not @d4.is_obstructed?(2, 5), 'Should be false'
    # A8 -> A6 => false
    assert_not @a8.is_obstructed?(1, 6), 'Should be false'
    # A8 -> C8 => false
    assert_not @a8.is_obstructed?(3, 8), 'Should be false'
  end

  test "should capture black piece" do
    # Test white Knight capturing a black Pawn
    assert @d4.move_to!(5, 2), "White knight can't capture black pawn?"
    # Reload the Pawn object to refresh its captured attribute
    @e2.reload
    assert @e2.captured?, "Black pawn not captured?"
  end

  test "should capture white piece" do
    @game.turn = @player_2.id

    # Test black Knight capturing a white Bishop
    assert @c7.move_to!(1, 6), "Black knight can't capture white bishop?"
    # Reload the Bishop object to refresh its captured attribute
    @a6.reload
    assert @a6.captured?, "White bishop not captured?"
  end

  test 'capturing of pieces' do
    # Test white Knight capturing a black Pawn
    assert @d4.move_to!(5, 2), "White knight can't capture black pawn?"
    # Reload the Pawn object to refresh its captured attribute
    @e2.reload
    assert @e2.captured?, 'Black pawn not captured?'

    @game.turn = @player_2.id

    # Test black Pawn capturing a white Knight
    assert @e5.move_to!(4, 4), "Black pawn can't capture white Knight?"
    # Reload the Knight object to refresh its captured attribute
    @d4.reload
    assert @d4.captured?, 'White Knight not captured?'
  end

  test 'should cause check' do
    # Test white Rook putting black King in check
    @f6.move_to! 6, 5
    assert @f6.game.in_check?(@f6.color), 'Game not in check?'
  end

  test 'should prevent entering check' do
    # Test black King avoiding moving into check
    assert_not @c5.move_to! 3, 6
    assert_not @c5.game.in_check?(@c5.color), 'Black King entered check?'
  end

  test 'should eliminate check' do
    # Test that a black Rook rescues black King from being in check
    @c5.move_to! 4, 5
    @f6.move_to! 6, 5
    assert @f6.game.in_check?(@f6.color), 'Game not in check?'

    @e6.move_to! 5, 5
    assert_not @e6.game.in_check?(@e6.color), 'Game still in check?'
  end
  
end
