require 'test_helper'

class CheckMateTest < ActionDispatch::IntegrationTest

  def setup
    @game = games(:one)
    @player_1 = players(:player_1)
     
    log_in_as @player_1, { password: '123greetings' }
    
  # white pieces
    Rook.create(game: @game, x_coordinate: 1, y_coordinate: 1, color: 'white')
    Rook.create(game: @game, x_coordinate: 8, y_coordinate: 1, color: 'white')
 
    Knight.create(game: @game, x_coordinate: 2, y_coordinate: 1, color: 'white')
    Knight.create(game: @game, x_coordinate: 7, y_coordinate: 1, color: 'white')
 
    Bishop.create(game: @game, x_coordinate: 3, y_coordinate: 1, color: 'white')
    Bishop.create(game: @game, x_coordinate: 6, y_coordinate: 1, color: 'white')
 
    Queen.create(game: @game, x_coordinate: 4, y_coordinate: 1, color: 'white')
    King.create(game: @game, x_coordinate: 5, y_coordinate: 1, color: 'white')

   # black pieces
    Rook.create(game: @game, x_coordinate: 1, y_coordinate: 8, color: 'black')
    Rook.create(game: @game, x_coordinate: 8, y_coordinate: 8, color: 'black')
 
    Knight.create(game: @game, x_coordinate: 2, y_coordinate: 8, color: 'black')
    Knight.create(game: @game, x_coordinate: 7, y_coordinate: 8, color: 'black')
 
    Bishop.create(game: @game, x_coordinate: 3, y_coordinate: 8, color: 'black')
    Bishop.create(game: @game, x_coordinate: 6, y_coordinate: 8, color: 'black')
 
    @d8 = Queen.create(game: @game, x_coordinate: 4, y_coordinate: 8, color: 'black')
    King.create(game: @game, x_coordinate: 5, y_coordinate: 8, color: 'black')
 
  # pawns
    @white_pawns = {}
    @black_pawns = {}

    (1..8).each do |i|
      @white_pawns[i] = Pawn.create(game: @game, x_coordinate: i, y_coordinate: 2, color: 'white')
      @black_pawns[i] = Pawn.create(game: @game, x_coordinate: i, y_coordinate: 7, color: 'black')
    end
  end
  
  test "should result in checkmate" do
    put game_piece_path(game_id: @game, id: @white_pawns[6], piece: { id: @white_pawns[6], x_coordinate: 6, y_coordinate: 3 })
    @white_pawns[6].reload
    
    put game_piece_path(game_id: @game, id: @black_pawns[5], piece: { id: @black_pawns[5], x_coordinate: 5, y_coordinate: 5 })
    @black_pawns[5].reload
    
    put game_piece_path(game_id: @game, id: @white_pawns[7], piece: { id: @white_pawns[7], x_coordinate: 7, y_coordinate: 4 })
    @white_pawns[7].reload
    
    put game_piece_path(game_id: @game, id: @d8, piece: { id: @d8, x_coordinate: 8, y_coordinate: 4 })
    
    assert @game.ends_by_checkmate?(@d8.color), "Checkmate did not occur?"
  end

end
