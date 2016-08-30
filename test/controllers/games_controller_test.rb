require 'test_helper'

class GamesControllerTest < ActionController::TestCase
	
	def setup
		@player_1 = players(:player_1)
		@player_3 = players(:player_3)
		@game_1 = games(:one)
		@game_3 = games(:three)
	end

	test "should create a game that persists and redirects to show" do
		player_2 = players(:player_2)
		sign_in player_2

		params = { 
			game: {
				white_player_id: player_2.id,
      	black_player_id: nil
			}
		}

		post :create, params
		game = assigns(:game)
		assert game.persisted?
		assert_redirected_to game
	end

	test "joining a game" do
    game = @game_3
    player = @player_3
    sign_in player
    patch :update, id: game.id, game: { black_player_id: player.id }
    game.reload
    assert_response :found
    assert_redirected_to game_path(game)
    assert game.black_player_id == player.id
  end
end
