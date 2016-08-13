class Piece < ActiveRecord::Base
  belongs_to :game

  def move_to!(x, y)
  # Open ActiveRecord transaction block (enables rollback of piece move if it would cause check)
    self.transaction do
    # Immediately return to pieces#update with false if the player associated
    # with the moving piece does not match the player owning the current turn
      return false unless player_id == game.turn
      
    # Return to controller with false if moving piece is obstructed
      return false if is_obstructed? x, y
      
    # Return to controller with false if coordinates of piece movement path violate specific piece's boundaries
      return false unless valid_move? x, y
      
    # Return to controller with false if a player piece other than the moving piece occupies the target destination
      return false if player_piece_occupies_destination? x, y
      
    # Return to controller with true if an opponent piece is captured
      return true if piece_captured? x, y
      
    # Roll back piece move and return to controller with false if it will cause check
      raise ActiveRecord::Rollback if move_would_cause_check? x, y

    # Check if an en passant capture opportunity exists
      if game.en_passant_opportunity_active?
        game.update_attribute(:allows_en_passant_capture?, true)
      else
        game.update_attribute(:allows_en_passant_capture?, false) if game.allows_en_passant_capture?
      end
      
    # Return true: the piece move is valid
      true
    end
  end

  # Returns true/false if a piece is obstructed in its movement.
  def is_obstructed?(x, y)
    # Immediately return false if moving piece is a Knight, which is exempt from obstruction
    return false if type.eql? 'Knight'

    # Create shorter names for x and y coordinates
    pos_x = x_coordinate
    pos_y = y_coordinate

    # Determine the increments for each coordinate in pathway_positions array.
    increment_x = pos_x <=> x
    increment_y = pos_y <=> y

    # Determine the range of the pathway
    range = (pos_x - x).abs > (pos_y - y).abs ? (pos_x - x).abs : (pos_y - y).abs

    pathway_positions = []

    # Push all positions between the piece and the proposed coordinate to array.
    range.times { pathway_positions << [x += increment_x, y += increment_y] }

    # Remove Piece's position to omit from the following check.
    pathway_positions.delete [pos_x, pos_y]

    # Check if any items in array are obstructed using contains_piece? method.
    pathway_positions.any? { |a, b| game.contains_piece?(a, b) }
  end

  def player_piece_occupies_destination?(x, y)
  # Query for player piece in target destination
    player_piece = game.pieces.where(x_coordinate: x, y_coordinate: y, color: color, captured?: false).last
  
  # Return false if player_piece is nil
    return false if player_piece.nil?
  # If player_piece is not nil and is the moving piece, return false; otherwise return true
    player_piece == self ? false : true
  end

  def piece_captured?(x, y)
  # Query for opponent piece in target destination
    opponent_piece = game.pieces.where(x_coordinate: x, y_coordinate: y, captured?: false).where.not(color: color).last

  # Return false if opponent_piece is the King, which can't be captured
    return false if opponent_piece && opponent_piece.type.eql?('King')
    
  # If an opponent pieces occupies the moving piece's targeting destination and is captured, return true; otherwise return false
    ( opponent_piece && opponent_piece.update_attribute(:captured?, true) ) ? true : false
  end
  
  def move_would_cause_check?(proposed_x, proposed_y)
  # Store moving piece's starting coordinates so they can be restored prior to method's false return if necessary
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
      # Skip this iteration if the current opponent_piece would be obstructed while attempting to move to the player king's position
        next if opponent_piece.is_obstructed? pkx, pky
      # Restore the moving piece's coordinates to their starting values
        update_attributes x_coordinate: current_x, y_coordinate: current_y
      # If both criteria are met, at least once opponent_piece would successfully 'check' the player king
        return true
      end
    end
    
  # If the player king would not enter 'check' as a result of the proposed move, restore the piece's coordinates to their
  # starting values so the move_to! call can finish its operations
    update_attributes x_coordinate: current_x, y_coordinate: current_y
    
  # Return false: no opponent_piece would 'check' the player king
    false
  end

end
