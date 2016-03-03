class Piece < ActiveRecord::Base
  belongs_to :game
  
# Allows piece to move if the move is valid and a friendly piece does not occupy the target destination
# Also allows pieces to be captured
  def move_to!(x, y)
  # Set friendly pieces
    # set_friendly_pieces
  # Set enemy pieces
    # set_enemy_pieces

  # Immediately return to controller with false if move is determined invalid
    return false if !valid_move? x, y

  # Return to controller with false if a friendly piece occupies the target destination
    return false if friendly_piece_occupies_destination? x, y

  # Return to controller with true if an enemy piece is captured
    return true if capture_piece? x, y

  # The move is still valid if the processing reaches this point
    true
  end
  
  private

    def set_friendly_pieces
    # Collect remaining friendly pieces, but not the currently-moving piece
      # @friendly_pieces ||= game.pieces.where(color: color).where.not(id: self)
    end

    def set_enemy_pieces
    # Collect remaining enemy pieces
      # @enemy_pieces ||= game.pieces.where.not(color: color)
    end

    def friendly_piece_occupies_destination?(x, y)
    # Check if a friendly piece occupies the targeted destination
      #game.pieces.where(x_coordinate: x, y_coordinate: y).any? ? true : false
      @friendly_pieces.each do |friendly_piece|
        return true if friendly_piece.x_coordinate == x && friendly_piece.y_coordinate == y
      end
      
      false
    end
    
    def capture_piece?(x, y)
    # Check if an enemy piece occupies the targeted destination  
      # enemy_piece = game.pieces.where.not(color: color).where(x_coordinate: x, y_coordinate: y)
      # return true if enemy_piece && enemy_piece.destroy
      # false
      @enemy_pieces.each do |enemy_piece|
        if enemy_piece.x_coordinate == x && enemy_piece.y_coordinate == y
        # Remove the piece from the database if being captured
          enemy_piece.destroy
          return true
        end
      end
      
      false
    end
end
