class Piece < ActiveRecord::Base
  belongs_to :game

  def is_obstructed?(x, y) # WORK IN PROGRESS
    pieces.where(x_coordinate: x, y_coordinate: y)
  end

end
