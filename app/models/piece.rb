class Piece < ActiveRecord::Base
  belongs_to :game

  def is_obstructed?(x, y) # WORK IN PROGRESS
  	#query if piece is located at the x, y array space
    pieces.where(x_coordinate: x, y_coordinate: y).last
    #with the valid move path from the last position
    #of the piece. 
  end

end
