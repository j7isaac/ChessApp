class StaticPagesController < ApplicationController
	
	helper_method :resource_name, :resource, :devise_mapping

	def index
		@open_games = Game.where(black_player_id: nil).where.not(white_player_id: current_player.id).first(12) if player_signed_in?
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

end
