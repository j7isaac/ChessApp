class Game < ActiveRecord::Base
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
    set_remaining_piece_data color
    
    @remaining_player_pieces.each do |player_piece|
    # Check if it would be valid for the current player_piece to move to the opponent king's position
      if player_piece.valid_move? @okx, @oky
      # Check if the current player_piece wouldn't obstructed while attempting to move to the opponent king's position
        unless player_piece.is_obstructed? @okx, @oky
        # Store reference to player piece causing check
          @player_piece_causing_check = player_piece
        # Store player_piece coordinates for shorter reference elsewhere
          @x_of_threat = player_piece.x_coordinate
          @y_of_threat = player_piece.y_coordinate
        # If both criteria are met, at least one player_piece is 'checking' the opponent king
          return true
        end
      end
    end

  # Return false: no player_piece is 'checking' the opponent king
    false
  end
  
  def ends_by_checkmate?(color)
  # Return false immediately unless the game is in check
    return false unless in_check? color
  # Return false if opponent can capture the piece(s) causing check
    return false if opponent_can_capture_piece_causing_check? color
  # Return false if opponent can block the piece(s) causing check
    return false if opponent_can_block_piece_causing_check? color
  # Return false if opponent king can escape check
    return false if checked_king_can_escape?

    true
  end
  
  def opponent_can_capture_piece_causing_check?(color)
    @remaining_opponent_pieces.each do |opponent_piece|
    # Skip this iteration if the opponent_piece is a pawn that couldn't capture the piece causing check
      if opponent_piece.type.eql? 'Pawn'
        next if ( opponent_piece.x_coordinate - @x_of_threat ).abs != 1 || ( opponent_piece.y_coordinate - @y_of_threat ).abs != 1
      end
      
    # Check if it would be valid for the opponent_piece to move to the position of the piece causing check
      if opponent_piece.valid_move? @x_of_threat, @y_of_threat
      # Check if the opponent_piece wouldn't obstructed while attempting to move to the position of the piece causing check
        unless opponent_piece.is_obstructed? @x_of_threat, @y_of_threat
        # If both criteria are met, at least one opponent_piece can capture the piece causing check
          return true
        end
      end
    end
    
  # Return false: no opponent_piece can capture the player piece causing check
    false
  end
  
  def opponent_can_block_piece_causing_check?(color)
  # Immediately return false if the player piece causing check is a Knight, which can't be blocked
    return false if @player_piece_causing_check.type.eql? 'Knight'
  
  # Remove the opponent king from the remaining_opponent_pieces array, since it can't be involved in blocking
    @remaining_opponent_pieces.delete_if { |remaining_opponent_piece| remaining_opponent_piece.type.eql? 'King' }
  
  # Store the coordinate sets between the player piece causing check and the opponent king
    in_between_coordinates = set_coordinates_between_piece_causing_check_and_opponent_king
    
  # Iterate through coordinate sets between piece causing check, and opponent king
    in_between_coordinates.each do |x_of_threat, y_of_threat|
      @remaining_opponent_pieces.each do |opponent_piece|
      # Check if it would be valid for the opponent_piece move to the specified
      # coordinate set between the piece causing check and opponent king
        if opponent_piece.valid_move? x_of_threat, y_of_threat
        # Check if the opponent_piece wouldn't obstructed while attempting to move
        # to the specified coordinate set between the piece causing check 
          unless opponent_piece.is_obstructed? x_of_threat, y_of_threat
          # If both criteria are met, at least one opponent_piece can block the piece causing check
            return true
          end
        end
      end
    end
    
  # Return false: no opponent_piece can block the player piece causing check
    false
  end
  
  def checked_king_can_escape?
  # Store opponent_king coordinates locally
    okx = @okx
    oky = @oky
    
  # Build two-dimensional array of opponent king's surrounding coordinate sets
  # (leave behind any coordinate sets that contain a 0 or 9 (would be invalid moves))
    possible_escape_coordinates_for_king = [
      [okx, oky - 1],
      [okx, oky + 1],
      [okx + 1, oky],
      [okx - 1, oky],
      [okx - 1, oky - 1],
      [okx - 1, oky + 1],
      [okx + 1, oky - 1],
      [okx + 1, oky + 1]
    ].delete_if { |coordinate_set| coordinate_set.include? 0 }
     .delete_if { |coordinate_set| coordinate_set.include? 9 }
    
  # Iterate through opponent king's valid surrounding coordinate sets
    possible_escape_coordinates_for_king.each do |escape_x, escape_y|
    # Check if it would be valid for the opponent_king to move to the specified surrounding coordinate set
      if @opponent_king.valid_move? escape_x, escape_y
      # Check if the opponent_king wouldn't obstructed while attempting to move to the specified surrounding coordinate set
        unless @opponent_king.is_obstructed? escape_x, escape_y
        # Check if a player piece doesn't occupy the specified surrounding coordinate set
          unless @opponent_king.player_piece_occupies_destination? escape_x, escape_y
          # Check if the opponent_king wouldn't enter check while attempting to move to the specified surroudning coordinate set
            unless @opponent_king.move_would_cause_check? escape_x, escape_y
            # If above criteria are met, the opponent_king can escape check
              return true
            end
          end
        end
      end
    end

  # Return false: the opponent_king can not escape check
    false
  end
  
  def set_remaining_piece_data(color)
  # Query for remaining player pieces
    @remaining_player_pieces = pieces.where(game_id: id, color: color, captured?: false)
  # Query for remaining opponent pieces
    @remaining_opponent_pieces = pieces.where(game_id: id, captured?: false).where.not(color: color)
  # Grab the king from @remaining_opponent_pieces
    @opponent_king = @remaining_opponent_pieces.select { |remaining_opponent_piece| remaining_opponent_piece.type.eql? 'King' }.last

  # Store opponent_king coordinates for shorter reference
    @okx = @opponent_king.x_coordinate
    @oky = @opponent_king.y_coordinate
  end
  
  def set_coordinates_between_piece_causing_check_and_opponent_king
  # Store coordinates of player piece causing check locally
    x_of_threat = @x_of_threat
    y_of_threat = @y_of_threat
  
  # Initialize array that will hold coordinate sets between player piece causing check and opponent king
    coordinate_path_to_king = []
    
  # If the x coordinate of the piece causing check matches the opponent king x
  # coordinate, build a coordinate path in which only the y coordinate needs to change
    if @x_of_threat == @okx
      if @y_of_threat > @oky
        @y_of_threat.downto(@oky).each { |y| coordinate_path_to_king << [x_of_threat, y] }
      else
        @y_of_threat.upto(@oky).each { |y| coordinate_path_to_king << [x_of_threat, y] }
      end
  # If the y coordinate of the piece causing check matches the opponent king y
  # coordinate, build a coordinate path in whch only the x coordinate needs to change
    elsif @y_of_threat == @oky
      if @x_of_threat > @okx
        @x_of_threat.downto(@okx).each { |x| coordinate_path_to_king << [x, y_of_threat] }
      else
        @x_of_threat.upto(@okx).each { |x| coordinate_path_to_king << [x, y_of_threat] }
      end
  # If neither the x or y coordinates of the piece causing check match the opponent king x or y
  # coordinates, build a diagonal coordinate path
    else
      if @x_of_threat < @okx
        if @y_of_threat > @oky
          @x_of_threat.upto(@okx).each do |x|
            coordinate_path_to_king << [x, y_of_threat]
            y_of_threat -= 1
          end
        else
          @x_of_threat.upto(@okx).each do |x|
            coordinate_path_to_king << [x, y_of_threat]
            y_of_threat += 1
          end
        end
      else
        if @y_of_threat > @oky
          @x_of_threat.downto(@okx).each do |x|
            coordinate_path_to_king << [x, y_of_threat]
            y_of_threat -= 1
          end
        else
          @x_of_threat.downto(@okx).each do |x|
            coordinate_path_to_king << [x, y_of_threat]
            y_of_threat += 1
          end
        end
      end
    end
    
  # Return coordinate_path_to_king without the first and last sets of coordinates
  # (i.e. where the player piece is moving & where the opponent king is)
    coordinate_path_to_king.shift
    coordinate_path_to_king.pop
    coordinate_path_to_king
  end
  
  def is_finished?
    winning_player_id.nil? ? false : true
  end

end
