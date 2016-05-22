class Game < ActiveRecord::Base
  attr_writer :en_passant_capture_opportunity
  
  has_many :pieces

  after_create :populate_board!

  # Returns true/false if a coordinate contains a piece.
  def contains_piece?(x, y)
    # Determines if a piece is at given location.
    pieces.where(x_coordinate: x, y_coordinate: y, captured?: false).present?
  end

  def create_pieces(color, row, pawn_row)
    # Enumerator of Piece types in the correct order for chess
    non_pawn = [Rook, Knight, Bishop, Queen, King, Bishop, Knight, Rook].to_enum
    # Creates each Piece type in 'non_pawn' plus a pawn
    non_pawn.with_index(1).each do |piece, i|
      piece.create(game_id: id, x_coordinate: i, y_coordinate: row, color: color)
      Pawn.create(game_id: id, x_coordinate: i, y_coordinate: pawn_row, color: color)
    end
  end

  def populate_board!
    # white pieces
    create_pieces 'white', 1, 2
    # black pieces
    create_pieces 'black', 8, 7
  end

  def in_check?(color)
    # Query for remaining friendly pieces
    player_pieces = pieces.where(game_id: id, color: color, captured?: false)

    # Query for enemy king piece
    enemy_king = pieces.where(game_id: id, type: 'King').where.not(color: color).last

    # Store enemy_king coordinates for shorter reference
    ekx = enemy_king.x_coordinate
    eky = enemy_king.y_coordinate

    player_pieces.each do |player_piece|
      # Check if it would be valid for the current player_piece to move to the enemy king's position
      if player_piece.valid_move? ekx, eky
        # Check if the current player_piece wouldn't obstructed while attempting to move to the enemy king's position
        unless player_piece.is_obstructed? ekx, eky
          # If both criteria are met, at least once player_piece is successfully 'checking' the enemy king
          return true
        end
      end
    end
    # Return false if no player_piece is 'checking' the enemy king
    false
  end


  def en_passant_opportunity_active?
    @en_passant_capture_opportunity
  end

end
