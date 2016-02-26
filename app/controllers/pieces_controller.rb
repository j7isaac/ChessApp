class PiecesController < ApplicationController
  before_action :set_piece, only: [:show, :update]
  
  def show
    @game = Piece.find(params[:id]).game
    @pieces = @game.pieces
  end
  
  def update
    if @piece.update_attributes(piece_params)
      redirect_to @piece.game
    else
      render :show
    end
  end
  
  private
  
    def set_piece
      @piece = Piece.find(params[:id])
    end
  
    def piece_params
      params.require(:piece).permit(:id, :x_coordinate, :y_coordinate)
    end
  
end