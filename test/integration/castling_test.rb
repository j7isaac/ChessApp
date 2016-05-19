require 'test_helper'

class CastlingTest < ActionDispatch::IntegrationTest
  def setup
    @game = games(:one)

    @king_w = King.create(game: @game, color: 'white', x_coordinate: 5, y_coordinate: 1)
    @king_b = King.create(game: @game, color: 'black', x_coordinate: 5, y_coordinate: 8)

    @rook_1w = Rook.create(game: @game, color: 'white', x_coordinate: 1, y_coordinate: 1)
    @rook_2w = Rook.create(game: @game, color: 'white', x_coordinate: 8, y_coordinate: 1)

    @rook_1b = Rook.create(game: @game, color: 'black', x_coordinate: 1, y_coordinate: 8)
    @rook_2b = Rook.create(game: @game, color: 'black', x_coordinate: 8, y_coordinate: 8)
  end

  test 'should castle king-side for white king' do
    create_castle @king_w, @rook_2w, 7, 1

    validate_castle 'King', 7, 6, @king_w, @rook_2w
  end

  test 'should castle queen-side for white king' do
    create_castle @king_w, @rook_1w, 3, 1

    validate_castle 'Queen', 3, 4, @king_w, @rook_1w
  end

  test 'should castle king-side for black king' do
    create_castle @king_b, @rook_2b, 7, 8

    validate_castle 'King', 7, 6, @king_b, @rook_2b
  end

  test 'should castle queen-side for black king' do
    create_castle @king_b, @rook_1b, 3, 8

    validate_castle 'Queen', 3, 4, @king_b, @rook_1b
  end

  private

  def create_castle(king, rook, x, y)
    put game_piece_path(game_id: @game, id: king, piece: { id: king, x_coordinate: x, y_coordinate: y })

    king.reload
    rook.reload
  end

  def validate_castle(type, kx, rx, king, rook)
    assert_equal kx, king.x_coordinate, "#{type}-side castle for #{king.color} king failed? (king move)"
    assert_equal rx, rook.x_coordinate, "#{type}-side castle for #{king.color} king failed? (rook auto-move)"
  end
end
