class Piece < ActiveRecord::Base
  belongs_to :game

  def move_to!(x, y)
  # Open Active Record transaction block (forces roll back of player move if it would cause check)
    self.transaction do
    # Return to controller with false if moving piece is obstructed
      return false if is_obstructed? x, y
      
    # Immediately return to controller with false if move is deemed invalid
      return false unless valid_move? x, y
      
    # Return to controller with false if a friendly piece occupies the target destination
      return false if friendly_piece_occupies_destination? x, y
      
    # Return to controller with true if a piece is captured
      return true if piece_captured? x, y
      
    # Roll back player's move and return to controller with false if moving piece will cause check
      raise ActiveRecord::Rollback if move_would_cause_check? x, y

    # Check if an en passant capture opportunity exists
      if game.en_passant_opportunity_active?
        game.update_attribute(:allows_en_passant_capture?, true)
      else
        game.update_attribute(:allows_en_passant_capture?, false) if game.allows_en_passant_capture?
      end
      
    # The move remains valid if the processing reaches this point
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

  def friendly_piece_occupies_destination?(x, y)
  # Query for friendly piece in target destination
    friendly_piece = game.pieces.where(x_coordinate: x, y_coordinate: y, color: color, captured?: false).last
  
  # Check if a friendly piece occupies the targeted destination  
    if friendly_piece
    # Check if friendly_piece is the moving piece
      if friendly_piece == self
        return false
      else
        return true
      end
    end
  end

  def piece_captured?(x, y)
  # Query for enemy piece in target destination
    enemy_piece = game.pieces.where(x_coordinate: x, y_coordinate: y, captured?: false).where.not(color: color).last

  # Check if an enemy piece occupies the target destination and is successfully captured
    ( enemy_piece && enemy_piece.update_attribute(:captured?, true) ) ? true : false
  end
  
  def move_would_cause_check?(proposed_x, proposed_y)
  # Store piece's original coordinates so they can be restored prior to method's false return if necessary
    current_x = x_coordinate
    current_y = y_coordinate

  # Temporarily force piece's coordinates to be updated with proposed new coordinates so looping logic below can
  # accurately determine if check would be caused
    update_attributes x_coordinate: proposed_x, y_coordinate: proposed_y

  # Query for remaining remaining enemy pieces
    enemy_pieces = game.pieces.where.not(color: color).where(captured?: false)

  # Query for friendly king piece
    friendly_king = game.pieces.where(type: 'King', color: color).last

  # Store friendly_king coordinates for shorter reference
    fkx = friendly_king.x_coordinate
    fky = friendly_king.y_coordinate

    enemy_pieces.each do |enemy_piece|
    # Check if it would be valid for the current enemy_piece to move to the friendly king's position
      if enemy_piece.valid_move? fkx, fky
      # Check if the current enemy_piece wouldn't obstructed while attempting to move to the friendly king's position
        unless enemy_piece.is_obstructed? fkx, fky
        # If both criteria are met, at least once enemy_piece would successfully 'check' the friendly king
          return true
        end
      end
    end
    
  # If the friendly king would not be 'in check' as a result of the proposed move, restore the piece's coordinates to their
  # original values so the move_to! call can finish its operations
    update_attributes x_coordinate: current_x, y_coordinate: current_y
    
  # Return false if no enemy_piece would 'check' the friendly king
    false
  end

end
