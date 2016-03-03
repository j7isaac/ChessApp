class Piece < ActiveRecord::Base
  belongs_to :game

  # Returns true/false if a piece is obstructed in it's movement.
  # Errors for movements not diagonal, vertical or horizontal
  def is_obstructed?(x, y)
    # Checks if method is dealing with a diagonal, vertical or horzonital movement.
    # If not error is raised.
    if x == x_coordinate or y == y_coordinate
      # Check each item in given array for an obstruction using contains_piece? method.
      horizontal_vertical_array(x, y).any? {|h, v| game.contains_piece?(h, v) == true }
    elsif (x_coordinate - x).abs == (y_coordinate - y).abs
      # Check each item in given array for an obstruction using contains_piece? method.
      diagonal_array(x, y).any? {|h, v| game.contains_piece?(h, v) == true }
    else
      raise ArgumentError, 'Invalid input. Not diagonal, horizontal, or vertical.'
    end
  end

  # Outputs an array of coordinates between Piece and destination in a horizontal/vertical movement.
  # Does not include destination coordinate nor Piece coordinate.
  def horizontal_vertical_array(x, y)
    # Create array
    pathway_spaces = []
    # Make coordinates available locally to avoid erroneous changes.
    pos_x = x_coordinate
    pos_y = y_coordinate
    # Checks what axis the movement is relative to.
    if y == pos_y
      # Store increment values to be used for directional purposes.
      x_increment = x > pos_x ? 1 : -1
      # Ensure Piece coordinate is excluded from array.
      pos_x += x_increment
      # Loop through values stopping before 0.
      while (x - pos_x).abs > 0
        # Push the value to array.
        pathway_spaces << [pos_x, pos_y]
        # Move to next space using increment variable.
        pos_x += x_increment
      end
    elsif x == pos_x
      # Store increment values to be used for directional purposes.
      y_increment = y > pos_y ? 1 : -1
      # Ensure Piece coordinate is excluded from array.
      pos_y += y_increment
      # Loop through values stopping before 0.
      while (y - pos_y).abs > 0
        # Push the value to array.
        pathway_spaces << [pos_x, pos_y]
        # Change value to next space using increment variable.
        pos_y += y_increment
      end
    end
    # Return array
    pathway_spaces
  end

  # Outputs an array of coordinates between Piece and destination in a diagonal movement.
  # Does not include destination coordinate nor Piece coordinate.
  def diagonal_array(x, y)
    # Create array
    pathway_spaces = []
    # Make coordinates available locally to avoid erroneous changes.
    pos_x = x_coordinate
    pos_y = y_coordinate
    # Store increment values to be used for directional purposes.
    x_increment = x > pos_x ? 1 : -1
    y_increment = y > pos_y ? 1 : -1
    # Ensure Piece coordinate is excluded from array.
    pos_x += x_increment
    pos_y += y_increment
    # Loop through x and y values stopping before [0, 0].
    while (x - pos_x).abs > 0 && (y - pos_y).abs > 0
      # Push the value to array.
      pathway_spaces << [pos_x, pos_y]
      # Change value to next space using increment variable.
      pos_x += x_increment
      pos_y += y_increment
    end
    # Return array
    pathway_spaces
  end

end