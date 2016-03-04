class Piece < ActiveRecord::Base
  belongs_to :game

  def move_to!(x, y)
  # Immediately return to controller with false if move is deemed invalid
    return false if !valid_move? x, y

  # Return to controller with false if moving piece is obstructed
    return false if is_obstructed? x, y

  # Return to controller with false if a friendly piece occupies the target destination
    return false if friendly_piece_occupies_destination? x, y

  # Return to controller with true if an enemy piece is captured
    return true if enemy_piece_captured? x, y

  # The move remains valid if the processing reaches this point
    true
  end

  # Returns true/false if a piece is obstructed in its movement.
  # Errors for movements not diagonal, vertical or horizontal
    def is_obstructed?(x, y)
    # Immediately return false if moving piece is a Knight, which is exempt from obstruction
      return false if type.eql? 'Knight'

    # Checks if method is dealing with a diagonal, vertical or horizontal movement.
    # If not error is raised.
      if x == x_coordinate || y == y_coordinate
      # Check each item in given array for an obstruction using contains_piece? method.
        horizontal_vertical_array(x, y).any? {|h, v| game.contains_piece?(h, v) }
      elsif (x_coordinate - x).abs == (y_coordinate - y).abs
      # Check each item in given array for an obstruction using contains_piece? method.
        diagonal_array(x, y).any? {|h, v| game.contains_piece?(h, v) }
      else
        raise ArgumentError, 'Invalid move: not diagonal, horizontal, or vertical.'
      end
    end
  
  # Outputs an array of coordinates between Piece and destination in a horizontal/vertical movement.
  # Does not include destination coordinate or Piece coordinate.
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
  # Does not include destination coordinate or Piece coordinate.
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
  
  private

    def friendly_piece_occupies_destination?(x, y)
    # Query for friendly piece in target destination
      friendly_piece = game.pieces.where(x_coordinate: x, y_coordinate: y, color: color).last
    
    # Check if a friendly piece occupies the targeted destination  
      friendly_piece ? true : false
    end

    def enemy_piece_captured?(x, y)
    # Query for enemy piece in target destination
      enemy_piece = game.pieces.where.not(color: color).where(x_coordinate: x, y_coordinate: y).last

    # Check if an enemy piece occupies the target destination and is successfully captured
      ( enemy_piece && enemy_piece.destroy ) ? true : false
    end

end
