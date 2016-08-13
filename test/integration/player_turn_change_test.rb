require 'test_helper'

class PlayerTurnChangeTest < ActionDispatch::IntegrationTest
  
  def setup
    @player_1 = players(:player_1)
    @player_2 = players(:player_2)
    
    log_in_as @player_1, { password: '123greetings' }
    log_in_as @player_2, { password: '123greetings' }
    
    post_via_redirect games_path, game: { white_player_id: @player_1.id }
    
    @game = assigns(:game)
    
    @white_pawn = @game.pieces.where(type: 'Pawn', color: 'white', x_coordinate: 6, y_coordinate: 2, player_id: @player_1.id).last
    @black_pawn = @game.pieces.where(type: 'Pawn', color: 'black', x_coordinate: 2, y_coordinate: 7).last
  end

  test "should grant white player the first turn" do
    assert_equal @player_1.id, @game.turn, "White player not granted first turn?"
  end

  test "should prevent first turn until black player has joined the game" do
    @game.update_attribute(:black_player_id, nil)
    
    put game_piece_path(game_id: @game, id: @white_pawn, piece: { id: @white_pawn, x_coordinate: 6, y_coordinate: 3 })
    @white_pawn.reload
    
    assert_not flash.empty?
    assert_equal "Please wait... You do not have an opponent for this Game yet.", flash[:warning], "Black player has joined the game?"
    
    assert_equal 6, @white_pawn.x_coordinate, "First move executed without black player?"
    assert_equal 2, @white_pawn.y_coordinate, "First move executed without black player?"
    
    assert_not @white_pawn.has_moved?, "First move executed without black player?"
  end

  test "should prevent white player from moving a black piece" do
    @game.update_attribute(:black_player_id, @player_2.id)
    @black_pawn.update_attribute(:player_id, @player_2.id)
    
    put game_piece_path(game_id: @game, id: @black_pawn, piece: { id: @black_pawn, x_coordinate: 2, y_coordinate: 6 })
    @black_pawn.reload
    
    assert_equal 2, @black_pawn.x_coordinate, "White player can move a black piece?"
    assert_equal 7, @black_pawn.y_coordinate, "White player can move a black piece?"
    
    assert_not @black_pawn.has_moved?, "White player can move a black piece?"
  end

  test "should grant execution of first turn after black player joins game" do
    @game.update_attribute(:black_player_id, @player_2.id)

    put game_piece_path(game_id: @game, id: @white_pawn, piece: { id: @white_pawn, x_coordinate: 6, y_coordinate: 3 })
    @white_pawn.reload

    assert_equal 6, @white_pawn.x_coordinate, "First move not executed?"
    assert_equal 3, @white_pawn.y_coordinate, "First move not executed?"
    
    assert @white_pawn.has_moved?, "First move not executed?"
  end

  test "should grant black player the second turn" do
    @game.update_attribute(:black_player_id, @player_2.id)

    put game_piece_path(game_id: @game, id: @white_pawn, piece: { id: @white_pawn, x_coordinate: 6, y_coordinate: 3 })
    @white_pawn.reload
    @game.reload
    
    assert_equal @player_2.id, @game.turn, "Black player not granted second turn?"
  end

  test "should prevent black player from moving a white piece" do
    @game.update_attribute(:black_player_id, @player_2.id)
    
    put game_piece_path(game_id: @game, id: @white_pawn, piece: { id: @white_pawn, x_coordinate: 6, y_coordinate: 3 })
    @white_pawn.reload
    @game.reload

    put game_piece_path(game_id: @game, id: @white_pawn, piece: { id: @white_pawn, x_coordinate: 6, y_coordinate: 4 })
    @white_pawn.reload
    
    assert_equal 6, @white_pawn.x_coordinate, "Black player can move a white piece?"
    assert_equal 3, @white_pawn.y_coordinate, "Black player can move a white piece?"
  end

end
