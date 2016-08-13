require 'test_helper'

class PlayerLeaveTest < ActionDispatch::IntegrationTest
  
  def setup
    @player_1 = players(:player_1)
    @player_2 = players(:player_2)
    
    log_in_as @player_1, { password: '123greetings' }
    
    post_via_redirect games_path, game: { white_player_id: @player_1.id }
    
    @game = assigns(:game)
    
    @white_pawn = @game.pieces.where(type: 'Pawn', color: 'white', x_coordinate: 7, y_coordinate: 2).last
  end

  test "should redirect white player to home page when game's only player" do
    patch game_path(@game), game: { white_player_id: "" }
    
    assert_not Game.exists?(@game), "Game not deleted?"
    
    res = JSON.parse(response.body)
    
    assert_equal "/", res['redraw_game_url'], "White player not redirected to home page?"
    
    assert_not flash.empty?
    assert_equal "The Game you left now no longer exists. You can create a new Game or join a Game that is Open.", flash[:info], "Message incorrect for white player only leaving?"
  end

  test "should redirect white player to home page after moving once" do
    patch game_path(@game), game: { black_player_id: @player_2.id }
    assert_redirected_to @game
    @game.reload
    
    put game_piece_path(game_id: @game, id: @white_pawn, piece: { id: @white_pawn, x_coordinate: 7, y_coordinate: 3 })
    
    patch game_path(@game), game: { white_player_id: "" }
    
    assert_not Game.exists?(@game), "Game not deleted?"
    
    res = JSON.parse(response.body)
    
    assert_equal "/", res['redraw_game_url'], "White player not redirected to home page?"
    
    assert_not flash.empty?
    assert_equal "Your Game has been cancelled. You can create a new Game or join a Game that is open.", flash[:info], "Message incorrect for white player leaving (after 1 move)?"
  end

end
