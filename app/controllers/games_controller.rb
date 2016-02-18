class GamesController < ApplicationController
	before_action :authenticate_player!

  def new
  end
end
