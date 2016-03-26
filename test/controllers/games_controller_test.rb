require 'test_helper'

class GamesControllerTest < ActionController::TestCase
	
	def setup
		@game = games(:one)
		@player_1 = players(:player_1)
		@player_2 = players(:player_2)
	end
=begin
	test "should get new" do
		sign_in @player_1
		
		get :new
		
		assert_response :success
		
		assert_template 'games/new'
	end

	test "should create a new game object" do
		sign_in @player_1
		
		get :new, { white_player_id: @player_1.id }
		
		game = assigns(:game)
		
		assert game.new_record?
		
		assert_response :success
	end

	test "should create a game that persists and redirects to show" do
		sign_in @player_2

		post :create, game: { white_player_id: @player_2.id }
		
		game = assigns(:game)
		
		assert game.persisted?
		
		assert_redirected_to game
	end
=end
  test "chess board should be wrapped by one parent div" do
		create_game
		
		assert_template 'games/show'
    
    assert_select 'div#chessboard', count: 1
  end

  test "chess board should contain 8 rows of spaces" do
    create_game

    assert_select 'div.board-row', count: 8
  end
   
  test "chess board should contain 64 individual spaces" do
    create_game
    
    assert_select 'div.chessboard-space', count: 64
  end

	private
	
		def create_game
			sign_in @player_1
	
			post :create, game: { white_player_id: @player_1.id }
			
			game = assigns(:game)
	
	    get :show, id: game
	    
	    game
		end

end
