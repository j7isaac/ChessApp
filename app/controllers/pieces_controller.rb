class PiecesController < ApplicationController
  before_action :set_piece
  
  def update
    x = params[:piece][:x_coordinate].to_i
    y = params[:piece][:y_coordinate].to_i

    if @piece.move_to! x, y
      flash[:success] = "Move was valid" if @piece.update_attributes(piece_params)
    else
      flash[:danger] = "Move was invalid"
    end
    
    render json: {
      redraw_game_url: game_path(@piece.game)
    }
  end
  
  private
  
    def set_piece
      @piece ||= Piece.find(params[:id])
    end

    def piece_params
      params.require(:piece).permit(:id, :x_coordinate, :y_coordinate)
    end
  
end
