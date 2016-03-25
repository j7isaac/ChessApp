class Game < ActiveRecord::Base
  has_many :pieces

  after_create :populate_board!
  after_create :set_first_turn!
  # after_update :assign_black_pieces!

# Returns true/false if a coordinate contains a piece.
  def contains_piece?(x, y)
  # Determines if a piece is at given location.
    pieces.where(x_coordinate: x, y_coordinate: y, captured?: false).present?
  end
  
  def change_player_turn!(color)
    color.eql?("white") ? update_attribute(:turn, black_player_id) : update_attribute(:turn, white_player_id)
  end
  
  def assign_black_pieces!
    pieces.where(color: 'black').each { |piece| piece.update_attribute(:player_id, black_player_id) }
  end
  
  private

    def populate_board!
    # white pieces
      Rook.create(game_id: self.id, x_coordinate: 8, y_coordinate: 1, color: 'white', player_id: white_player_id)
      Rook.create(game_id: self.id, x_coordinate: 8, y_coordinate: 8, color: 'white', player_id: white_player_id)
  
      Knight.create(game_id: self.id, x_coordinate: 8, y_coordinate: 2, color: 'white', player_id: white_player_id)
      Knight.create(game_id: self.id, x_coordinate: 8, y_coordinate: 7, color: 'white', player_id: white_player_id)
  
      Bishop.create(game_id: self.id, x_coordinate: 8, y_coordinate: 3, color: 'white', player_id: white_player_id)
      Bishop.create(game_id: self.id, x_coordinate: 8, y_coordinate: 6, color: 'white', player_id: white_player_id)
  
      Queen.create(game_id: self.id, x_coordinate: 8, y_coordinate: 4, color: 'white', player_id: white_player_id)
      King.create(game_id: self.id, x_coordinate: 8, y_coordinate: 5, color: 'white', player_id: white_player_id)

    # black pieces
      Rook.create(game_id: self.id, x_coordinate: 1, y_coordinate: 1, color: 'black')
      Rook.create(game_id: self.id, x_coordinate: 1, y_coordinate: 8, color: 'black')
  
      Knight.create(game_id: self.id, x_coordinate: 1, y_coordinate: 2, color: 'black')
      Knight.create(game_id: self.id, x_coordinate: 1, y_coordinate: 7, color: 'black')
  
      Bishop.create(game_id: self.id, x_coordinate: 1, y_coordinate: 3, color: 'black')
      Bishop.create(game_id: self.id, x_coordinate: 1, y_coordinate: 6, color: 'black')
  
      Queen.create(game_id: self.id, x_coordinate: 1, y_coordinate: 4, color: 'black')
      King.create(game_id: self.id, x_coordinate: 1, y_coordinate: 5, color: 'black')
  
    # pawns
      [['white', 7], ['black', 2]].each do |color, x|
        (1..8).each do |i|
          color.eql?('white') ? player = white_player_id : player = nil
          Pawn.create(game_id: self.id, x_coordinate: x, y_coordinate: i, color: color, player_id: player)
        end  
      end
    end
    
    def set_first_turn!
      update_attribute(:turn, white_player_id)
    end
    
end
