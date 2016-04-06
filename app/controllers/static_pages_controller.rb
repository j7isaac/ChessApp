class StaticPagesController < ApplicationController
	
	helper_method :resource_name, :resource, :devise_mapping

	def index
	  @game = Game.new
	  
	  if current_player
	    if unfinished_game_for_player_as_white? || unfinished_game_for_player_as_black?
	      set_unfinished_game
	    end
	  end
	  
		@unfinished_games = Game.where(black_player_id: nil).where.not(white_player_id: current_player.id).first(12) if player_signed_in?
	end
	
	def resource_name
	  :player
	end
 
  def resource
    @resource ||= Player.new
  end
 
  def devise_mapping
    @devise_mapping ||= Devise.mappings[:player]
  end
  
  private
  
    def unfinished_game_for_player_as_white?
      Game.where(winning_player_id: nil, white_player_id: current_player.id).where.not(black_player_id: nil).any? ? true : false
    end
    
    def unfinished_game_for_player_as_black?
      Game.where(winning_player_id: nil, black_player_id: current_player.id).where.not(white_player_id: nil).any? ? true : false
    end
    
    def set_unfinished_game
      if unfinished_game_for_player_as_white?
        @unfinished_game = Game.where(winning_player_id: nil, white_player_id: current_player.id).where.not(black_player_id: nil).last
        @opponent = Player.find(@unfinished_game.black_player_id).email
      end
      
      if unfinished_game_for_player_as_black?
        @unfinished_game = Game.where(winning_player_id: nil, black_player_id: current_player.id).where.not(white_player_id: nil).last
        @opponent = Player.find(@unfinished_game.white_player_id).email
      end
    end

end
