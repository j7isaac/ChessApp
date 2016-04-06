require 'test_helper'

class BishopTest < ActiveSupport::TestCase
  
  def setup
    game = games(:one)
    
    @bishop_1w = Bishop.create(game: game, color: 'white', x_coordinate: 3, y_coordinate: 4, captured?: false)
  end
  
  test "valid moves" do
    assert @bishop_1w.valid_move? 6, 7
    assert @bishop_1w.valid_move? 1, 2
    assert @bishop_1w.valid_move? 1, 6
    assert @bishop_1w.valid_move? 5, 6
  end

  test "invalid moves" do
    assert_not @bishop_1w.valid_move? 5, 7
    assert_not @bishop_1w.valid_move? 3, 7
    assert_not @bishop_1w.valid_move? 1, 4
  end
  
end
