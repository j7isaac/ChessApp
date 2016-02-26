class Queen < Piece
	def valid_move?(x,y)
		x_coordinate == x || y_coordinate == y || (x_coordinate-x).abs == (y_coordinate - y).abs
	end
end
