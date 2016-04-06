require 'test_helper'

class QueenTest < ActiveSupport::TestCase
  
  def setup
    game = games(:one)
    
    @queen_w = Queen.create(game: game, color: 'white', x_coordinate: 8, y_coordinate: 4, captured?: false)
    @queen_b = Queen.create(game: game, color: 'black', x_coordinate: 1, y_coordinate: 4, captured?: false)
  end

# Tests for the white queen to move from its starting position

  test "queen_w should move from X8/Y4 to X8/Y3" do
    assert @queen_w.valid_move?(8, 3), "queen_w can't move from X8/Y4 to X8/Y3?"
  end

  test "queen_w should move from X8/Y4 to X7/Y7" do
    assert @queen_w.valid_move?(7, 3), "queen_w can't move from X8/Y4 to X7/Y3?"
  end

# Tests for the black queen to move from its starting position

  test "queen_b should move from X1/Y4 to X3/Y2" do
    assert @queen_b.valid_move?(3, 2), "queen_b can't move from X1/Y4 to X3/Y2?"
  end

  test "queen_b should move from X1/Y4 to X4/Y4" do
    assert @queen_b.valid_move?(4, 4), "queen_b can't move from X1/Y2 to X4/Y4?"
  end

end
