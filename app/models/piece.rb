class Piece < ActiveRecord::Base
  belongs_to :game

  def is_obstructed?(x, y) # WORK IN PROGRESS
    obstructed_space = a_piece_at_its_space(x, y)
    return false if obstructed_space.empty?
    return true if obstructed_space #is not empty
    end
    end
  end

end
