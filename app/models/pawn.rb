class Pawn < Piece
  def valid_move?(x, y)
    # piece isn't required to move (turn not forfeited)
    return true if x == x_coordinate && y == y_coordinate

    # rule: pawn can't move backwards
    # black: y7 - y6 (a backward move) is > 0, so return false
    return false if color.eql?('black') && (y - y_coordinate) > 0
    # white: y3 - y2 (a backward move) is > 0, so return false
    return false if color.eql?('white') && (y_coordinate - y) > 0

    # rule: pawn can move forward two spaces from its starting point
    # => black pawn hasn't moved if its x_coordinate is 7 (since it can't move backwards)
    # white: y2 > y4 (4 == ( 2 + 2 ))
    # => white pawn hasn't moved if its x_coordinate is 2 (since it can't move backwards)
    if y == (y_coordinate - 2) && (color.eql?('black') && y_coordinate == 7) ||
       y == (y_coordinate + 2) && (color.eql?('white') && y_coordinate == 2)
      if ((y - y_coordinate ).abs == 2 ) && (x == x_coordinate )
        game.en_passant_capture_opportunity = true
        return true
      end
    end
    
    # Return true if Pawn executes valid en passant capture
    return true if en_passant_move? x, y

    # rule: pawn captures enemy pieces with diagonal move
    # Collect remaining enemy pieces
    enemy_pieces = game.pieces.where(captured?: false).where.not(color: color)

    # Check if an enemy piece occupies the targeted destination
    enemy_pieces.each do |enemy_piece|
      if ((x - x_coordinate).abs == 1 && (y - y_coordinate).abs == 1) &&
         (enemy_piece.x_coordinate == x && enemy_piece.y_coordinate == y)
        return true
      end
    end
    
    # rule: pawn moves forward one space
    if x_coordinate == x
      return true if (color.eql?('black') || color.eql?('white')) && (y - y_coordinate).abs == 1
    end
  end

  def en_passant_move?(x, y)
  # Return false immediately if the game doesn't currently allow an en passant capture (the opportunity lasts one turn)
    return false unless game.allows_en_passant_capture?
    
  # Return false if the Pawn is not sitting at the fifth rank
    return false if ( color.eql?('white') && y_coordinate != 5 ) || ( color.eql?('black') && y_coordinate != 4 )
    
  # Query for a capturable pawn
    capturable_pawn = game.pieces.where(x_coordinate: x, y_coordinate: y_coordinate).where.not(color: color).last
    
  # Check if a pawn is vulernable to an en passant capture
    if capturable_pawn && (x - x_coordinate).abs == 1
      if color.eql?('white')
      # Capture the vulnerable pawn if the white pawn is executing a capture move
        capturable_pawn.update_attribute(:captured?, true) if y == 6
      
      # Return true at this point for a successful en passant capture
        return true
      else
      # Capture the vulnerable pawn if the black pawn is executing a capture move
        capturable_pawn.update_attribute(:captured?, true) if y == 3

      # Return true at this point for a successful en passant capture
        return true
      end
    end
  
  # Return false at this point: an en passant capture did not occur
    false
  end

end
