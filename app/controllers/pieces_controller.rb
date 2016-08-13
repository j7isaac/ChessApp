class PiecesController < ApplicationController
  before_action :set_piece
  before_action :set_game
  
  def update
    x = params[:piece][:x_coordinate].to_i
    y = params[:piece][:y_coordinate].to_i
    
    if @game.is_finished?
      flash[:info] = "Thank you for playing! This Game is finished."
    else
      if opponent_exists?
        if valid_player_turn?
          if @piece.move_to! x, y
            message =  "#{@piece.color.capitalize} #{@piece.type} has moved to X#{x}/Y#{y}."
            
            if @piece.has_moved?
              flash[:success] = message if @piece.update_attributes(piece_params)
            else
              flash[:success] = message if @piece.update_attributes(piece_params.merge(has_moved?: true))
            end
            
            if @game.ends_by_checkmate? @piece.color
              set_game_winner
              
              flash[:info] = "Checkmate! #{Player.find(@game.winning_player_id).email} has won this Game!"
            else
              @game.change_player_turn! @piece.color
              
              color = @piece.color.eql?('white') ? "Black" : "White"
              
              flash[:warning] = "#{color} King is currently in check." if @game.in_check?(@piece.color)
            end
          else
            flash[:danger] = "#{@piece.color.capitalize} #{@piece.type} move to X#{x}/Y#{y} is invalid. Please make a valid move."
          end
        else
          flash[:warning] = "Please wait... Your opponent has not taken their turn yet."
        end
      else
        flash[:warning] = "Please wait... You do not have an opponent for this Game yet."
      end
    end
    
    refresh_game
  end
  
  private

    def set_piece
      @piece = Piece.find(params[:id])
    end
    
    def set_game
      @game = @piece.game
    end
    
    def opponent_exists?
      @game.black_player_id ? true : false
    end
    
    def valid_player_turn?
      @game.turn == current_player.id ? true : false
    end

    def piece_params
      params.require(:piece).permit(:id, :x_coordinate, :y_coordinate, :type)
    end
    
    def refresh_game
      render json: {
        redraw_game_url: game_path(@game)
      }
    end
    
    def set_game_winner
      @game.update_attribute(:winning_player_id, current_player.id)
    end
  
end
