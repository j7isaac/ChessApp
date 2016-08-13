require 'test_helper'

class GamesControllerTest < ActionController::TestCase
	
	def setup
		@player_1 = players(:player_1)
		@player_2 = players(:player_2)
		
		@game_1 = games(:one)
		@game_2 = games(:three)
	end

	test "should create a game that persists and redirects to show" do
		sign_in @player_2

		post :create, game: { white_player_id: @player_2.id }
		
		game = assigns(:game)
		
		assert game.persisted?
		
		assert_redirected_to game
	end

	test "joining a game" do
    game = @game_2
    player = @player_2
    
    sign_in player
    
    patch :update, id: game.id, game: { black_player_id: player.id }
    game.reload
    
    assert_response :found
    assert_redirected_to game_path(game)
    assert_equal player.id, game.black_player_id, "Game's black Player not #{player.email}?"
  end

end
