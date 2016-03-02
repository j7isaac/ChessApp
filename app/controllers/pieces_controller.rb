class PiecesController < ApplicationController
  before_action :set_piece, only: [:show, :update]
  before_action :set_friendly_pieces, only: :update
  
  def show
    @game = Piece.find(params[:id]).game
    @pieces = @game.pieces
  end
  
  def update
    x = params[:piece][:x_coordinate].to_i
    y = params[:piece][:y_coordinate].to_i

    if @piece.valid_move?(x, y) && !friendly_piece_occupies_destination?(x, y)
      flash[:success] = "Move was valid" if @piece.update_attributes(piece_params)
    else
      flash[:danger] = "Move was invalid"
    end
    
    redirect_to @piece.game
  end
  
  private
  
    def set_piece
      @piece = Piece.find(params[:id])
    end
    
    def set_friendly_pieces
    # Collect non-captured friendly pieces, but not the currently-moving piece
      @friendly_pieces ||= @piece.game.pieces.where(color: @piece.color, captured?: false).where.not(id: @piece)      
    end
    
    def friendly_piece_occupies_destination?(x, y)
    # Check if a friendly piece occupies the targeted destination  
      @friendly_pieces.each do |friendly_piece|
        return true if friendly_piece.x_coordinate == x && friendly_piece.y_coordinate == y
      end
      
      false
    end
  
    def piece_params
      params.require(:piece).permit(:id, :x_coordinate, :y_coordinate)
    end
  
end
