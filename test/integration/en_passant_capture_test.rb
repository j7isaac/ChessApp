require 'test_helper'

class EnPassantCaptureTestTest < ActionDispatch::IntegrationTest
  
  def setup
    @game = games(:one)
    
    @B7 = Pawn.create(game: @game, color: 'black', x_coordinate: 2, y_coordinate: 7)
    @G8 = Pawn.create(game: @game, color: 'white', x_coordinate: 7, y_coordinate: 8)
    @A2 = Knight.create(game: @game, color: 'black', x_coordinate: 1, y_coordinate: 2)
  end
  
  test "should execute valid en passant capture" do
    validate_en_passant_opportunity @G8, 5, 8
    
    invalidate_en_passant_opportunity @A2, 3, 1
    
    invalidate_en_passant_opportunity @G8, 4, 8
    
    invalidate_en_passant_opportunity @A2, 5, 2
    
    validate_en_passant_opportunity @B7, 4, 7
    
    move_to! @G8, 3, 7

    @B7.reload

    assert @B7.captured?, "Black Pawn not captured?"
    assert_not @game.allows_en_passant_capture?, "En passant opportunity exists?"
  end
  
  private
  
    def move_to!(piece, x, y)
      put game_piece_path(game_id: @game, id: piece, piece: { id: piece, x_coordinate: x, y_coordinate: y })
      piece.reload
      @game.reload
    end

    def validate_en_passant_opportunity(piece, x, y)
      move_to! piece, x, y

      assert @game.allows_en_passant_capture?, "En passant opportunity does not exist?"
    end
    
    def invalidate_en_passant_opportunity(piece, x, y)
      move_to! piece, x, y

      assert_not @game.allows_en_passant_capture?, "En passant opportunity exists?"
    end
  
end
