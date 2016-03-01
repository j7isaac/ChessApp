class PiecesController < ApplicationController
  before_action :set_piece, only: [:show, :update]
  
  def show
    @game = Piece.find(params[:id]).game
    @pieces = @game.pieces
  end
  
  def update
    x = params[:piece][:x_coordinate].to_i
    y = params[:piece][:y_coordinate].to_i

    if @piece.move_to!(x, y)
      flash[:success] = "Move was valid" if @piece.update_attributes(piece_params)
    else
      flash[:danger] = "Move was invalid"
    end
    
    redirect_to @piece.game
  end
  
  private
  
    def set_piece
      @piece ||= Piece.find(params[:id])
    end
  
    def piece_params
      params.require(:piece).permit(:id, :x_coordinate, :y_coordinate)
    end
  
end
