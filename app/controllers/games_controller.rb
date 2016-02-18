class GamesController < ApplicationController
	before_action :authenticate_player!
	helper_method :game

  def new
  	@game = Game.new
  end

  def create
    @game = Game.create(game_params)
    redirect_to game_path(@game)
  end

  def show
  end

  private

  def game
    @game ||= Game.where(id: params[:id]).last
  end

end
