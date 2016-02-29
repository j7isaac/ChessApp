require 'test_helper'

class GameTest < ActiveSupport::TestCase
	attr_accessor :game

	def setup
    @game = games(:one)
    Rook.create(game: game, color: 'white', x_coordinate: 8, y_coordinate: 1, captured?: false)
    Pawn.create(game: game, color: 'white', x_coordinate: 7, y_coordinate: 1, captured?: false)
    Queen.create(game: game, color: 'black', x_coordinate: 1, y_coordinate: 4, captured?: false)
    Bishop.create(game: game, color: 'white', x_coordinate: 1, y_coordinate: 3, captured?: false)
  end

  test 'whats_at? method - Should correctly identify what is at a given location on board'  do
    assert_instance_of Rook, @game.whats_at?(8, 1)
    assert_instance_of Pawn, @game.whats_at?(7, 1)
    assert_instance_of Queen, @game.whats_at?(1, 4)
    assert_instance_of Bishop, @game.whats_at?(1, 3)
    assert_nil @game.whats_at?(3, 3), 'nil'
  end
end

# rake test:units