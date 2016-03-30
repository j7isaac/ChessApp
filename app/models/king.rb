class King < Piece
    
  def valid_move?(x, y)
  # Where x is the new position, and x_coordinate is the previous position, .abs to ensure value is not negative
    delta_x = (x - x_coordinate).abs
  # Where y is the new position, and y_coordinate is the previous position, .abs to ensure value is not negative
    delta_y = (y - y_coordinate).abs
    
    ( delta_x <= 1 && delta_y <= 1 ) || castle_move?(x, y)
  end

  def castle_move?(x, y)
  # Return false if King has moved or both Rooks have moved
    return false if has_moved? || game.pieces.where(type: 'Rook', color: color, has_moved?: true).count == 2
    
  # Return false if King isn't moving two spaces
    return false if ( y - y_coordinate ).abs != 2
  
  # Validate that the king is moving along its home row
    if x == x_coordinate
    # Check if castling attempt is King-side
      if y > y_coordinate
      # Query for King-side Rook
        king_side_rook = game.pieces.where(type: 'Rook', color: color, y_coordinate: 8).last
  
      # If the King-side Rook hasn't moved, move it now; otherwise return false
        king_side_rook ? king_side_rook.update_attribute(:y_coordinate, 6) : false
  
      # Return true at this point for a successful castle move
        return true
    # If castling attempting is Queen-side
      else
      # Query for Queen-side Rook
        queen_side_rook = game.pieces.where(type: 'Rook', color: color, y_coordinate: 1).last
        
      # If the Queen-side Rook hasn't moved, move it now; otherwise return false
        queen_side_rook ? queen_side_rook.update_attribute(:y_coordinate, 4) : false

      # Return true at this point for a successful castle move
        return true
      end
    end

  # Return false at this point: a castle did not occur
    false
  end
  
end
