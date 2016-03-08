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
 
    # Checks if method is dealing with diagonal, vertical or horizontal movement.
    # If not error is raised.
    if (x_coordinate - x).abs == (y_coordinate - y).abs || x == x_coordinate || y == y_coordinate
    # Check each item in given array for an obstruction using contains_piece? method.
      pathway_array(x, y).any? {|h, v| game.contains_piece?(h, v) }
    else
      raise ArgumentError, 'Invalid move: not diagonal, horizontal, or vertical.'
    end
  end

# Outputs an array of coordinates between Piece and destination.
# Vertical, horizontal and diagonal movements only.
# Does not include Piece or destination coordinates.
  def pathway_array(x, y)
    pathway_spaces = []

  # Make coordinates available locally to avoid erroneous changes.
    pos_x = x_coordinate
    pos_y = y_coordinate

  # Determine the increments based on destination position relative to Piece.
    x_increment = x <=> x_coordinate
    y_increment = y <=> y_coordinate

  # Determine if pathway is horizontal, vertical or diagonal then loop.
    if (x_coordinate - x).abs == (y_coordinate - y).abs
    # Diagonal pathway loop
      while (x - pos_x).abs > 0 && (y - pos_y).abs > 0
        pathway_spaces << [pos_x, pos_y]
        pos_x += x_increment
        pos_y += y_increment
      end
    elsif x == x_coordinate
    # Vertical pathway loop
      while (y - pos_y).abs > 0
        pathway_spaces << [pos_x, pos_y]
        pos_y += y_increment
      end
    else
      while (x - pos_x).abs > 0
      # Horizontal pathway loop
        pathway_spaces << [pos_x, pos_y]
        pos_x += x_increment
      end
    end
  # Delete first position, which is Piece's position.
    pathway_spaces.delete_at 0
    pathway_spaces
  end

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
