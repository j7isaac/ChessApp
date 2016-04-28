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
    # black: y7 > y5 (5 == ( 7 - 2 ))
    # => black pawn hasn't moved if its x_coordinate is 7 (since it can't move backwards)
    # white: y2 > y4 (4 == ( 2 + 2 ))
    # => white pawn hasn't moved if its x_coordinate is 2 (since it can't move backwards)
    if y == (y_coordinate - 2) && (color.eql?('black') && y_coordinate == 7) ||
       y == (y_coordinate + 2) && (color.eql?('white') && y_coordinate == 2)
      return true if ((y - y_coordinate).abs == 2) && (x_coordinate == x)
    end

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
end
