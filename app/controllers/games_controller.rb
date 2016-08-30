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
    if game.valid? && game.white_player_id != game_params[:black_player_id]
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

end
