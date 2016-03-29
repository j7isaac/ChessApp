class PiecesController < ApplicationController
  before_action :set_piece
  
  def update
    x = params[:piece][:x_coordinate].to_i
    y = params[:piece][:y_coordinate].to_i

    if opponent_exists?
      if valid_player_turn?
        if @piece.move_to! x, y
          flash[:success] = "Move was valid" if @piece.update_attributes(piece_params)
          @piece.game.change_player_turn! @piece.color
        else
          flash[:danger] = "Move was invalid"
        end
      else
        flash[:warning] = "Please wait for your turn."
      end
    else
      flash[:warning] = "Please wait for your opponent."
    end
    
    render json: {
      redraw_game_url: game_path(@piece.game)
    }
  end
  
  private
  
    def set_piece
      @piece = Piece.find(params[:id])
    end
    
    def opponent_exists?
      @piece.game.assign_black_pieces! if @piece.game.pieces.where(player_id: nil).any?
      @piece.game.black_player_id ? true : false
    end
    
    def valid_player_turn?
      @piece.game.turn == current_player.id ? true : false
    end

    def piece_params
      params.require(:piece).permit(:id, :x_coordinate, :y_coordinate)
    end
  
end
