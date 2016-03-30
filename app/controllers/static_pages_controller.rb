class StaticPagesController < ApplicationController
	
	helper_method :resource_name, :resource, :devise_mapping

	def index
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
