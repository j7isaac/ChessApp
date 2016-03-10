class StaticPagesController < ApplicationController
	
	def index
		@open_games = Game.where(black_player_id: nil).where.not(white_player_id: current_player.id).first(20) if player_signed_in?
	end
	
end
