class PiecesController < ApplicationController
  before_action :set_piece
  before_action :set_game
  
  def update
    x = params[:piece][:x_coordinate].to_i
    y = params[:piece][:y_coordinate].to_i
    
    if @piece.move_to! x, y
      flash[:success] = "#{@piece.color.capitalize} #{@piece.type} move to X#{x}/Y#{y} was valid" if @piece.update_attributes(piece_params.merge(has_moved?: true))
    else
      flash[:danger] = "#{@piece.color.capitalize} #{@piece.type} move to X#{x}/Y#{y} was invalid"
    end

    @piece.color.eql?('white') ? color = "Black" : color = "White"

    flash[:warning] = "#{color} King is in check" if @game.in_check?(@piece.color)
    
    render json: {
      redraw_game_url: game_path(@game)
    }
  end
  
  private

    def set_piece
      @piece = Piece.find(params[:id])
    end
    
    def set_game
      @game = @piece.game
    end

    def piece_params
      params.require(:piece).permit(:id, :x_coordinate, :y_coordinate, :type)
    end
  
end
