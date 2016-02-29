class Rook < Piece
	def valid_move?(x,y)
		x_coordinate == x || y_coordinate == y
	end
end
