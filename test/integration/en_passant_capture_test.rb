require 'test_helper'

class EnPassantCaptureTestTest < ActionDispatch::IntegrationTest
  
  def setup
    @game = games(:one)
    
    @e1 = King.create(game: @game, color: 'white', x_coordinate: 5, y_coordinate: 1)
    @e8 = King.create(game: @game, color: 'black', x_coordinate: 5, y_coordinate: 8)
    
    @g7 = Pawn.create(game: @game, color: 'black', x_coordinate: 7, y_coordinate: 7)
    @h2 = Pawn.create(game: @game, color: 'white', x_coordinate: 8, y_coordinate: 2)
    @b8 = Knight.create(game: @game, color: 'black', x_coordinate: 2, y_coordinate: 8)
  end
  
  test "should execute valid en passant capture" do
    validate_en_passant_opportunity @h2, 8, 4
    
    invalidate_en_passant_opportunity @b8, 3, 6
    
    invalidate_en_passant_opportunity @h2, 8, 5
    
    invalidate_en_passant_opportunity @b8, 5, 5
    
    validate_en_passant_opportunity @g7, 7, 5
    
    move_to! @h2, 7, 6

    @g7.reload

    assert @g7.captured?, "Black Pawn not captured?"
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
