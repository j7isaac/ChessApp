class GamesController < ApplicationController
	before_action :authenticate_player!

	helper_method :game

  def create
    @game = Game.create(game_params)
    redirect_to @game
  end

  def show
    @game = Game.find(params[:id])
    @pieces = @game.pieces.where(captured?: false)
  end

  def update
    if white_leaves_as_only_player?
      close_game
    elsif black_player_exists?
      if black_player_leaves_without_moving?
        update_game_for_white_after_black_leaves if current_player.id == game.white_player_id
        
        leave_game_open if current_player.id == game.black_player_id
      elsif both_players_have_moved?
        black_player = game_params[:black_player_id]
        white_player = game_params[:white_player_id]
        
        if black_player.eql? ""
          game.update_attribute(:winning_player_id, game.white_player_id)
          
          if current_player.id == game.white_player_id
            set_game_winner_for_remaining_player(game.black_player_id)
          else
            set_game_winner_for_leaving_player(game.white_player_id)
          end
        end
        
        if white_player.eql? ""
          game.update_attribute(:winning_player_id, game.black_player_id)
          
          if current_player.id == game.black_player_id
            set_game_winner_for_remaining_player(game.white_player_id)
          else
            set_game_winner_for_leaving_player(game.black_player_id)
          end
        end
      else
        cancel_game
      end
    elsif players_are_unique?
      game.update_attributes game_params
      redirect_to game
    end
  end

  private

    def game
      @game ||= Game.where(id: params[:id]).last
    end

    def game_params
      params.require(:game).permit(:white_player_id, :black_player_id)
    end
    
    def players_are_unique?
      ( game.valid? && ( game.white_player_id != game_params[:black_player_id] ) ) ? true : false
    end
    
    def black_player_exists?
      game.black_player_id ? true : false
    end
    
    def white_player_leaving?
      game_params[:white_player_id].eql?("") ? true : false
    end
    
    def black_player_leaving?
      game_params[:black_player_id].eql?("") ? true : false
    end
    
    def white_has_moved?
      game.pieces.where(color: 'white', has_moved?: true).any? ? true : false
    end
    
    def black_has_moved?
      game.pieces.where(color: 'black', has_moved?: true).any? ? true : false
    end
  
    def white_leaves_as_only_player?
      ( white_player_leaving? && game.black_player_id.nil? ) ? true : false
    end
    
    def black_player_leaves_without_moving?
      black_has_moved? ? false : true if black_player_leaving?
    end
    
    def both_players_have_moved?
      ( white_has_moved? && black_has_moved? ) ? true : false
    end
    
    def close_game
      game.destroy
      
      flash[:info] = "The Game you left now no longer exists. You can create a new Game or join a Game that is Open."
        
      render json: {
        redraw_game_url: root_path
      }
    end
    
    def cancel_game
      game.destroy
    
      flash[:info] = "Your Game has been cancelled. You can create a new Game or join a Game that is open."
        
      render json: {
        redraw_game_url: root_path
      }
    end
    
    def update_game_for_white_after_black_leaves
      flash[:info] = "#{show_player(game.black_player_id)} has left your Game. Please wait for a new opponent."
      game.update_attribute(:black_player_id, nil)
    
      render json: {
        redraw_game_url: game_path(game)
      }
    end
    
    def leave_game_open
      flash[:info] = "You left your Game with #{show_player(game.white_player_id)}. You can create a new Game or join a Game that is Open."
      game.update_attribute(:black_player_id, nil)
    
      render json: {
        redraw_game_url: root_path
      }
    end
    
    def set_game_winner_for_remaining_player(player)
      flash[:info] = "#{show_player(player)} has left your Game. Thus, you are the Winner by default."
        
      render json: {
        redraw_game_url: game_path(game)
      }
    end
    
    def set_game_winner_for_leaving_player(player)
      flash[:info] = "You left your Game with #{show_player(player)}, who has been recorded as the Winner."
      
      render json: {
        redraw_game_url: root_path
      }
    end

end
