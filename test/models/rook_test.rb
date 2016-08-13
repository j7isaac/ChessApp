require 'test_helper'

class RookTest < ActiveSupport::TestCase
	
  def setup
    game = games(:one)
    
    @rook_w1 = Rook.create(game: game, color: 'white', x_coordinate: 8, y_coordinate: 1, captured?: false)
    @rook_w2 = Rook.create(game: game, color: 'white', x_coordinate: 8, y_coordinate: 8, captured?: false)
    
    @rook_b1 = Rook.create(game: game, color: 'black', x_coordinate: 1, y_coordinate: 1, captured?: false)
    @rook_b2 = Rook.create(game: game, color: 'black', x_coordinate: 1, y_coordinate: 8, captured?: false)
	end
	
# testing valid move for white rooks
	test "rook_w1 should move from x8/y1 to x1y1" do 
		assert @rook_w1.valid_move?(1,1), "rook_w1 can't move to x1/y1?"
	end

	test "rook_w2 should move from x8/y8 to x8y1" do 
		assert @rook_w2.valid_move?(8,1), "rook_w2 can't move to x8/y1?"
	end

# testing valid moves for black rooks
	test "rook_b1 should move from x1/y1 to x3y1" do 
		assert @rook_b1.valid_move?(3,1), "rook_b1 can't move to x3y1?"
	end

	test "rook_b2 should move from x1/y1 to x1y4" do 
		assert @rook_b1.valid_move?(1,4), "rook_b2 can't move to x1y4?"
	end

end
