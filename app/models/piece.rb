class Piece < ActiveRecord::Base
  belongs_to :game

  def move_to!(x, y)
  # Open ActiveRecord transaction block (enables rollback of piece move if it would cause check)
    self.transaction do
    # Immediately return to controller with false if piece movement is obstructed
      return false if is_obstructed? x, y
      
    # Return to controller with false if piece movement is determined invalid
      return false unless valid_move? x, y
      
    # Return to controller with false if a player piece other than the moving piece occupies the target destination
      return false if player_piece_occupies_destination? x, y
      
    # Return to controller with true if an opponent piece is captured
      return true if piece_captured? x, y
      
    # Roll back piece move and return to controller with false if it will cause check
      raise ActiveRecord::Rollback if move_would_cause_check? x, y
      
    # Return true: the piece move is valid
      true
    end
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

  def player_piece_occupies_destination?(x, y)
  # Query for player piece in target destination
    player_piece = game.pieces.where(x_coordinate: x, y_coordinate: y, color: color, captured?: false).last
  
  # Check if player_piece is not nil
    if player_piece
    # If player_piece is the moving piece, return false; otherwise return true
      player_piece == self ? false : true
    else
      return false
    end
  end

  def piece_captured?(x, y)
  # Query for opponent piece in target destination
    opponent_piece = game.pieces.where(x_coordinate: x, y_coordinate: y, captured?: false).where.not(color: color).last

  # Immediately return false if opponent_piece is the King, which can't be captured
    return false if opponent_piece && opponent_piece.type.eql?('King')
    
  # If an opponent pieces occupies the moving piece's targeting destination and is captured, return true; otherwise return false
    ( opponent_piece && opponent_piece.update_attribute(:captured?, true) ) ? true : false
  end
  
  def move_would_cause_check?(proposed_x, proposed_y)
  # Store moving piece's original coordinates so they can be restored prior to method's false return if necessary
    current_x = x_coordinate
    current_y = y_coordinate

  # Temporarily force moving piece's coordinates to be updated with proposed new coordinates so looping logic below can
  # accurately determine if check would be caused
    update_attributes x_coordinate: proposed_x, y_coordinate: proposed_y

  # Query for remaining remaining opponent pieces
    opponent_pieces = game.pieces.where.not(color: color).where(captured?: false)

  # Query for player king piece
    player_king = game.pieces.where(type: 'King', color: color).last

  # Store player_king coordinates for shorter reference
    pkx = player_king.x_coordinate
    pky = player_king.y_coordinate

    opponent_pieces.each do |opponent_piece|
    # Check if it would be valid for the current opponent_piece to move to the player king's position
      if opponent_piece.valid_move? pkx, pky
      # Check if the current opponent_piece wouldn't obstructed while attempting to move to the player king's position
        unless opponent_piece.is_obstructed? pkx, pky
        # Restore the moving piece's coordinates to their original values
          update_attributes x_coordinate: current_x, y_coordinate: current_y
        # If both criteria are met, at least once opponent_piece would successfully 'check' the player king
          return true
        end
      end
    end
    
  # If the player king would not enter 'check' as a result of the proposed move, restore the piece's coordinates to their
  # original values so the move_to! call can finish its operations
    update_attributes x_coordinate: current_x, y_coordinate: current_y
    
  # Return false: no opponent_piece would 'check' the player king
    false
  end

end
