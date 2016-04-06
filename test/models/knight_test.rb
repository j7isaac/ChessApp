require 'test_helper'

class KnightTest < ActiveSupport::TestCase
  
  def setup
    game = games(:one)
    
    @knight_1w = Knight.create(game: game, color: 'white', x_coordinate: 8, y_coordinate: 2, captured?: false)
    @knight_2w = Knight.create(game: game, color: 'white', x_coordinate: 8, y_coordinate: 7, captured?: false)
    
    @knight_1b = Knight.create(game: game, color: 'black', x_coordinate: 1, y_coordinate: 2, captured?: false)
    @knight_2b = Knight.create(game: game, color: 'black', x_coordinate: 1, y_coordinate: 7, captured?: false)
  end

# Tests for the first white knight to move from its starting position

  test "k1w should move from X8/Y2 to X6/Y1" do
    assert @knight_1w.valid_move?(6, 1), "k1w can't move from X8/Y2 to X6/Y1?"
  end

  test "k1w should move from X8/Y2 to X6/Y3" do
    assert @knight_1w.valid_move?(6, 3), "k1w can't move from X8/Y2 to X6/Y3?"
  end

# Tests for the second white knight to move from its starting position

  test "k2w should move from X8/Y7 to X6/Y6" do
    assert @knight_2w.valid_move?(6, 8), "k2w can't move from X8/Y7 to X6/Y6?"
  end

  test "k2w should move from X8/Y7 to X6/Y8" do
    assert @knight_2w.valid_move?(6, 8), "k2w can't move from X8/Y7 to X6/Y8?"
  end

# Tests for the first black knight to move from its starting position

  test "k1b should move from X1/Y2 to X3/Y1" do
    assert @knight_1b.valid_move?(3, 1), "k1b can't move from X1/Y2 to X3/Y1?"
  end

  test "k1b should move from X1/Y2 to X3/Y3" do
    assert @knight_1b.valid_move?(3, 3), "k1b can't move from X1/Y2 to X3/Y3?"
  end

# Tests for the second black knight to move from its starting position

  test "k2b should move from X1/Y7 to X3/Y6" do
    assert @knight_2b.valid_move?(3, 6), "k2b can't move from X1/Y7 to X3/Y6?"
  end
  
  test "k2b should move from X1/Y7 to X3/Y8" do
    assert @knight_2b.valid_move?(3, 8), "k2b can't move from X1/Y7 to X3/Y8?"
  end

end
