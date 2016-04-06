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

  test "validate if a coordinate contains a piece" do
    assert game.contains_piece?(8, 1), 'Should be true'
    assert_not game.contains_piece?(6, 3), 'Should be false'
  end

end