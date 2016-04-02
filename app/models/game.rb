class Game < ActiveRecord::Base
  attr_writer :en_passant_capture_opportunity
  
  has_many :pieces

  after_create :populate_board!

# Returns true/false if a coordinate contains a piece.
  def contains_piece?(x, y)
  # Determines if a piece is at given location.
    pieces.where(x_coordinate: x, y_coordinate: y, captured?: false).present?
  end

  def populate_board!
  # white pieces
    Rook.create(game_id: id, x_coordinate: 8, y_coordinate: 1, color: 'white')
    Rook.create(game_id: id, x_coordinate: 8, y_coordinate: 8, color: 'white')

    Knight.create(game_id: id, x_coordinate: 8, y_coordinate: 2, color: 'white')
    Knight.create(game_id: id, x_coordinate: 8, y_coordinate: 7, color: 'white')

    Bishop.create(game_id: id, x_coordinate: 8, y_coordinate: 3, color: 'white')
    Bishop.create(game_id: id, x_coordinate: 8, y_coordinate: 6, color: 'white')

    Queen.create(game_id: id, x_coordinate: 8, y_coordinate: 4, color: 'white')
    King.create(game_id: id, x_coordinate: 8, y_coordinate: 5, color: 'white')

    (1..8).each do |i|
      Pawn.create(game_id: id, x_coordinate: 7, y_coordinate: i, color: 'white')
    end  
    
  # black pieces
    Rook.create(game_id: id, x_coordinate: 1, y_coordinate: 1, color: 'black')
    Rook.create(game_id: id, x_coordinate: 1, y_coordinate: 8, color: 'black')

    Knight.create(game_id: id, x_coordinate: 1, y_coordinate: 2, color: 'black')
    Knight.create(game_id: id, x_coordinate: 1, y_coordinate: 7, color: 'black')

    Bishop.create(game_id: id, x_coordinate: 1, y_coordinate: 3, color: 'black')
    Bishop.create(game_id: id, x_coordinate: 1, y_coordinate: 6, color: 'black')

    Queen.create(game_id: id, x_coordinate: 1, y_coordinate: 4, color: 'black')
    King.create(game_id: id, x_coordinate: 1, y_coordinate: 5, color: 'black')

    (1..8).each do |i|
      Pawn.create(game_id: id, x_coordinate: 2, y_coordinate: i, color: 'black')
    end 
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
