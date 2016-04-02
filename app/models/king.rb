class King < Piece
    
  def valid_move?(x, y)
  # Where x is the new position, and x_coordinate is the previous position, .abs to ensure value is not negative
    delta_x = (x - x_coordinate).abs
  # Where y is the new position, and y_coordinate is the previous position, .abs to ensure value is not negative
    delta_y = (y - y_coordinate).abs
    
    ( delta_x <= 1 && delta_y <= 1 ) || castle_move?(x, y)
  end

  def castle_move?(x, y)
  # Note: obstruction has already been checked by the first line of move_to!
  
  # rules: The King and the chosen Rook are on the player's first rank.
  #        Neither the King nor the chosen Rook has previously moved.
    return false if has_moved? || game.pieces.where(type: 'Rook', color: color, has_moved?: true).count == 2
    
  # Return false if King isn't moving two spaces
    return false if ( y - y_coordinate ).abs != 2
    
  # Helps to ask next if the game is in check from the opponent's perspective
    enemy_king_color = color.eql?('white') ? 'black' : 'White'
    
  # rule: The King is not currently in check.
    return false if game.in_check? enemy_king_color
    
  # Validate that the king is moving along its home row
    if x == x_coordinate
    # Check if castling attempt is King-side
      if y > y_coordinate
      # rule: The King does not pass through a square that is attacked by an enemy piece.
      # rule: The king does not end up in check.
      # rule: There are no pieces between the King and the chosen Rook.
        unless enemy_piece_threatens_castle_path?(x, [6, 7]) || friendly_piece_blocks_castle_path?(x, [6, 7])
        # Query for King-side Rook
          king_side_rook = game.pieces.where(type: 'Rook', color: color, y_coordinate: 8).last
    
        # If the King-side Rook hasn't moved, move it now; otherwise return false
          king_side_rook ? king_side_rook.update_attribute(:y_coordinate, 6) : false
          
        # Return true at this point for a successful castle move
          return true
        end
    # If castling attempting is Queen-side
      else
      # rule: The King does not pass through a square that is attacked by an enemy piece.
      # rule: The king does not end up in check.
      # rule: There are no pieces between the King and the chosen Rook. 
        unless enemy_piece_threatens_castle_path?(x, [3, 4]) || friendly_piece_blocks_castle_path?(x, [2, 3, 4])
        # Query for Queen-side Rook
          queen_side_rook = game.pieces.where(type: 'Rook', color: color, y_coordinate: 1).last
          
        # If the Queen-side Rook hasn't moved, move it now; otherwise return false
          queen_side_rook ? queen_side_rook.update_attribute(:y_coordinate, 4) : false

        # Return true at this point for a successful castle move
          return true
        end
      end
    end

  # Return false at this point: a castle did not occur
    false
  end
  
  def enemy_piece_threatens_castle_path?(x, y_coordinates_of_path)
  # Query for remaining enemy pieces
    enemy_pieces = game.pieces.where(game_id: game.id, captured?: false).where.not(color: color)
    
    enemy_pieces.each do |enemy_piece|
      y_coordinates_of_path.each do |y|
        if enemy_piece.valid_move? x, y
          return true unless enemy_piece.is_obstructed? x, y
        end
      end
    end
  
  # Return false at this point: an enemy piece does not threaten the castle path
    false
  end

  def friendly_piece_blocks_castle_path?(x, y_coordinates_of_path)
    criteria = { game_id: game.id, color: color, x_coordinate: x, y_coordinate: y_coordinates_of_path, captured?: false }
    
  # Query for friendly pieces at x and y coordinates passed
  #   Return true if an enemy piece threatens the castle path; false otherwise
    game.pieces.where(criteria).where.not(id: id).any? ? true : false
  end
  
end
