require 'test_helper'

class KingTest < ActiveSupport::TestCase
  
  def setup
    game = games(:one)

    @king_w = King.create(game: game, color: 'white', x_coordinate: 5, y_coordinate: 1)
    @king_b = King.create(game: game, color: 'black', x_coordinate: 5, y_coordinate: 8)

    @rook_1w = Rook.create(game: game, color: 'white', x_coordinate: 1, y_coordinate: 1)
    @rook_2w = Rook.create(game: game, color: 'white', x_coordinate: 8, y_coordinate: 1)

    @rook_1b = Rook.create(game: game, color: 'black', x_coordinate: 1, y_coordinate: 8)
    @rook_2b = Rook.create(game: game, color: 'black', x_coordinate: 8, y_coordinate: 8)
  end

  # Tests for the white king to move from its starting position

  test 'king_w should move from X5/Y1 to X4/Y1' do
    assert @king_w.valid_move?(4, 1), "king_w can't move from X5/Y1 to X4/Y1?"
  end

  test 'king_w should move from X4/Y1 to X5/Y2' do
    assert @king_w.valid_move?(5, 2), "king_w can't move from X4/Y1 to X5/Y2?"
  end

  # Tests for the black king to move from its starting position

  test 'king_b should move from X5/Y8 to X6/Y8' do
    assert @king_b.valid_move?(6, 8), "queen_b can't move from X5/Y8 to X6/Y8?"
  end

  test 'king_b should move from X6/Y8 to X5/Y7' do
    assert @king_b.valid_move?(5, 7), "queen_b can't move from X6/Y8 to X5/Y7?"
  end

  # Tests castle_move?

  test 'should move king-side rook for castling white king' do
    assert @king_w.move_to!(7, 1)
    @rook_2w.reload
    assert_equal 6, @rook_2w.x_coordinate, 'King-side castle failed for white King?'
  end

  test 'should move queen-side rook for castling white king' do
    assert @king_w.move_to!(3, 1)
    @rook_1w.reload
    assert_equal 4, @rook_1w.x_coordinate, 'Queen-side castle failed for white King?'
  end

  test 'should move king-side rook for castling black king' do
    assert @king_b.move_to!(7, 8)
    @rook_2b.reload
    assert_equal 6, @rook_2b.x_coordinate, 'King-side castle failed for black King?'
  end

  test 'should move queen-side rook for castling black king' do
    assert @king_b.move_to!(3, 8)
    @rook_1b.reload
    assert_equal 4, @rook_1b.x_coordinate, 'Queen-side castle failed for black King?'
  end
  
end
