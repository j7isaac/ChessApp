class GamesController < ApplicationController
	before_action :authenticate_player!

	helper_method :game

  def new
  	@game = Game.new
  end

  def create
    @game = Game.create(game_params)
    redirect_to @game
  end

  def show
    @game = Game.find(params[:id])
    @pieces = @game.pieces.where(captured?: false)
  end

  private

  def game
    @game ||= Game.where(id: params[:id]).last
  end

  def game_params
    params.require(:game).permit(:white_player_id, :black_player_id)
  end

end
