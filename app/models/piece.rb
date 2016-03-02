class Piece < ActiveRecord::Base
  belongs_to :game

  def is_obstructed?(x, y)
    array = []
    if (x == x_coordinate) or (y == y_coordinate)
      horizontal_vertical_array(x, y).each do |h, v|
        array << game.contains_piece?(h, v)  
      end
      array.any?
    elsif (x_coordinate - x).abs == (y_coordinate - y).abs
      diagonal_array(x, y).each do |h, v|
        array << game.contains_piece?(h, v)  
      end
      array.any?
    else
      raise ArgumentError, 'Invalid input. Not diagonal, horizontal, or vertical.'
    end
  end

  def horizontal_vertical_array(x, y)
    array = []
    pos_x = x_coordinate
    pos_y = y_coordinate
    if y == pos_y
      x_increment = x > pos_x ? 1 : -1
      pos_x += x_increment
      while (x - pos_x).abs > 0
        array << [pos_x, pos_y]
        pos_x += x_increment
      end
    elsif x == pos_x
      y_increment = y > pos_y ? 1 : -1
      pos_y += y_increment
      while (y - pos_y).abs > 0
        array << [pos_x, pos_y]
        pos_y += y_increment
      end
    end
    array
  end

  def diagonal_array(x, y)
    array = []
    pos_x = x_coordinate
    pos_y = y_coordinate
    x_increment = x > pos_x ? 1 : -1
    y_increment = y > pos_y ? 1 : -1
    pos_x += x_increment
    pos_y += y_increment
    while (x - pos_x).abs > 0 && (y - pos_y).abs > 0
      array << [pos_x, pos_y]
      pos_x += x_increment
      pos_y += y_increment
    end
    array
  end

end