require 'test_helper'

class KingTest < ActiveSupport::TestCase
  def setup
    game = games(:one)
    @king_w = King.create(game: game, color: 'white', x_coordinate: 8, y_coordinate: 5, captured?: false)
    @king_b = King.create(game: game, color: 'black', x_coordinate: 1, y_coordinate: 5, captured?: false)
  end

# Tests for the white king to move from its starting position

  test "king_w should move from X8/Y5 to X8/Y4" do
    assert @king_w.valid_move?(8, 4), "king_w can't move from X8/Y4 to X8/Y3?"
  end

  test "king_w should move from X8/Y4 to X7/Y5" do
    assert @king_w.valid_move?(7, 5), "king_w can't move from X8/Y4 to X7/Y3?"
  end

# Tests for the black king to move from its starting position

  test "king_b should move from X1/Y5 to X1/Y6" do
    assert @king_b.valid_move?(1, 5), "queen_b can't move from X1/Y4 to X3/Y2?"
  end

  test "king_b should move from X1/Y5 to X2/Y5" do
    assert @king_b.valid_move?(2, 5), "queen_b can't move from X1/Y2 to X4/Y4?"
  end


end

