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
    # Check if it would be valid for the current player_piece to move to the enemy king's position
      if player_piece.valid_move? @ekx, @eky
      # Check if the current player_piece wouldn't obstructed while attempting to move to the enemy king's position
        unless player_piece.is_obstructed? @ekx, @eky
        # Store reference to player piece causing check
          @player_piece_causing_check = player_piece
        # Store player_piece coordinates for shorter reference
          @x_of_threat = player_piece.x_coordinate
          @y_of_threat = player_piece.y_coordinate
        # If both criteria are met, at least one player_piece is 'checking' the enemy king
          return true
        end
      end
    end

  # Return false: no player_piece is 'checking' the enemy king
    false
  end
  
  def ends_by_checkmate?(color)
  # Return false immediately unless the game is in check
    return false unless in_check? color
  # Return false if enemy can capture the piece(s) causing check
    return false if enemy_can_capture_piece_causing_check? color
  # Return false if enemy can block the piece(s) causing check
    return false if enemy_can_block_piece_causing_check? color
  # Return false if enemy king can escape check
    return false if checked_king_can_escape?

    true
  end
  
  def enemy_can_capture_piece_causing_check?(color)
    @remaining_enemy_pieces.each do |enemy_piece|
    # Skip this iteration if the enemy_piece is a pawn that couldn't capture the piece causing check
      if enemy_piece.type.eql? 'Pawn'
        next if ( enemy_piece.x_coordinate - @x_of_threat ).abs != 1 || ( enemy_piece.y_coordinate - @y_of_threat ).abs != 1
      end
      
    # Check if it would be valid for the enemy_piece move to the position of the piece causing check
      if enemy_piece.valid_move? @x_of_threat, @y_of_threat
      # Check if the enemy_piece wouldn't obstructed while attempting to move to the position of the piece causing check
        unless enemy_piece.is_obstructed? @x_of_threat, @y_of_threat
        # If both criteria are met, at least one enemy_piece can capture the piece causing check
          return true
        end
      end
    end
    
  # Return false: no enemy_piece can capture the player piece causing check
    false
  end
  
  def enemy_can_block_piece_causing_check?(color)
  # Immediately return false if the player piece causing check is a Knight, which can't be blocked
    return false if @player_piece_causing_check.type.eql? 'Knight'
  
  # Remove the enemy king from the remaining_enemy_pieces array, since it can't block the piece causing check
    @remaining_enemy_pieces.delete_if { |remaining_enemy_piece| remaining_enemy_piece.type.eql? 'King' }
  
  # Store the coordinate sets between the player piece causing check and the enemy king
    in_between_coordinates = set_coordinates_between_piece_causing_check_and_enemy_king
    
  # Iterate through coordinate sets between piece causing check, and enemy king
    in_between_coordinates.each do |x_of_threat, y_of_threat|
      @remaining_enemy_pieces.each do |enemy_piece|
      # Check if it would be valid for the enemy_piece move to the specified
      # coordinate set between the piece causing check and enemy king
        if enemy_piece.valid_move? x_of_threat, y_of_threat
        # Check if the enemy_piece wouldn't obstructed while attempting to move
        # to the specified coordinate set between the piece causing check 
          unless enemy_piece.is_obstructed? x_of_threat, y_of_threat
          # If both criteria are met, at least one enemy_piece can block the piece causing check
            return true
          end
        end
      end
    end
    
  # Return false: no enemy_piece can block the player piece causing check
    false
  end
  
  def checked_king_can_escape?
  # Store enemy_king coordinates locally
    ekx = @ekx
    eky = @eky
    
  # Build two-dimensional array of enemy king's surrounding coordinate sets
  # and remove any coordinate sets that contain a 0 or 9 (would be invalid moves)
    possible_escape_coordinates_for_king = [
      [ekx, eky - 1],
      [ekx, eky + 1],
      [ekx + 1, eky],
      [ekx - 1, eky],
      [ekx - 1, eky - 1],
      [ekx - 1, eky + 1],
      [ekx + 1, eky - 1],
      [ekx + 1, eky + 1]
    ].delete_if { |coordinate_set| coordinate_set.include? 0 }
     .delete_if { |coordinate_set| coordinate_set.include? 9 }
    
  # Iterate through enemy king's valid surrounding coordinate sets
    possible_escape_coordinates_for_king.each do |escape_x, escape_y|
    # Check if it would be valid for the enemy_king to move to the specified surrounding coordinate set
      if @enemy_king.valid_move? escape_x, escape_y
      # Check if the enemy_king wouldn't obstructed while attempting to move to the specified surrounding coordinate set
        unless @enemy_king.is_obstructed? escape_x, escape_y
        # Check if a piece friendly to the enemy_king doesn't occupy the specified surrounding coordinate set
          unless @enemy_king.friendly_piece_occupies_destination? escape_x, escape_y
          # Check if the enemy_king wouldn't enter check while attempting to move to the specified surroudning coordinate set
            unless @enemy_king.move_would_cause_check? escape_x, escape_y
            # If above criteria are met, the enemy_king can escape check
              return true
            end
          end
        end
      end
    end

  # Return false: the enemy_king can not escape check
    false
  end
  
  def set_remaining_piece_data(color)
  # Query for remaining friendly pieces
    @remaining_player_pieces = pieces.where(game_id: id, color: color, captured?: false)
  # Query for remaining enemy pieces
    @remaining_enemy_pieces = pieces.where(game_id: id, captured?: false).where.not(color: color)
  # Query for enemy king piece
    @enemy_king = pieces.where(game_id: id, type: 'King').where.not(color: color).last    

  # Store enemy_king coordinates for shorter reference
    @ekx = @enemy_king.x_coordinate
    @eky = @enemy_king.y_coordinate
  end
  
  def set_coordinates_between_piece_causing_check_and_enemy_king
    x_of_threat = @x_of_threat
    y_of_threat = @y_of_threat
    
    coordinate_path_to_king = []
    
  # If the x coordinate of the piece causing check matches the enemy king x
  # coordinate, build a coordinate path in which only the y coordinate needs to change
    if @x_of_threat == @ekx
      if @y_of_threat > @eky
        @y_of_threat.downto(@eky).each { |y| coordinate_path_to_king << [x_of_threat, y] }
      else
        @y_of_threat.upto(@eky).each { |y| coordinate_path_to_king << [x_of_threat, y] }
      end
  # If the y coordinate of the piece causing check matches the enemy king y
  # coordinate, build a coordinate path in whch only the x coordinate needs to change
    elsif @y_of_threat == @eky
      if @x_of_threat > @ekx
        @x_of_threat.downto(@ekx).each { |x| coordinate_path_to_king << [x, y_of_threat] }
      else
        @x_of_threat.upto(@ekx).each { |x| coordinate_path_to_king << [x, y_of_threat] }
      end
  # If neither the x or y coordinates of the piece causing check match the enemy king x or y
  # coordinates, build a diagonal coordiante path
    else
      if @x_of_threat < @ekx
        if @y_of_threat > @eky
          @x_of_threat.upto(@ekx).each do |x|
            coordinate_path_to_king << [x, y_of_threat]
            y_of_threat -= 1
          end
        else
          @x_of_threat.upto(@ekx).each do |x|
            coordinate_path_to_king << [x, y_of_threat]
            y_of_threat += 1
          end
        end
      else
        if @y_of_threat > @eky
          @x_of_threat.downto(@ekx).each do |x|
            coordinate_path_to_king << [x, y_of_threat]
            y_of_threat -= 1
          end
        else
          @x_of_threat.downto(@ekx).each do |x|
            coordinate_path_to_king << [x, y_of_threat]
            y_of_threat += 1
          end
        end
      end
    end
  # Return coordinate_path_to_king without the first and last sets of coordinates
  # (i.e. where the player piece is moving & where the enemy king is)
    coordinate_path_to_king.shift
    coordinate_path_to_king.pop
    coordinate_path_to_king
  end
  
  def is_finished?
    winning_player_id.nil? ? false : true
  end

end
