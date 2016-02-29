class Bishop < Piece
	def valid_move?(x, y)
  	(x_coordinate - x).abs == (y_coordinate - y).abs
  end
end
