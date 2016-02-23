require 'test_helper'

class GamesControllerTest < ActionController::TestCase
	test "should get new with Create game" do
		player1 = players(:player1)
		sign_in player1
		get :new, {}, { white_player_id: player1.id }
		game = assigns(:game)
		assert game.new_record?
		assert_response :success
	end

	test "should create game" do
		player = players(:player2)
		sign_in player
		params = {
			game: {
				white_player_id: player.id,
      	black_player_id: nil
			}
		}
		post :create, params, { white_player_id: player.id }
		game = assigns(:game)
		assert game.persisted?
		assert_redirected_to game_url(game)
	end



end
