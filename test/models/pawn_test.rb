require 'test_helper'

class PawnTest < ActiveSupport::TestCase
  
  def setup
    game = games(:one)

    @white_pawns = {}
    @black_pawns = {}

    (1..8).each do |i|
      @white_pawns[i] = Pawn.create(game: game, x_coordinate: i, y_coordinate: 2, color: 'white')
      @black_pawns[i] = Pawn.create(game: game, x_coordinate: i, y_coordinate: 7, color: 'black')
    end
  end

  # tests for white pawns

  test 'each white pawn may stay where it is' do
    @white_pawns.each do |k, white_pawn|
      assert white_pawn.valid_move?(k, 2), "p#{k}w can't stay in X#{k}/Y2?"
    end
  end

  test 'each white pawn should move one square from its starting position' do
    @white_pawns.each do |k, white_pawn|
      assert white_pawn.valid_move?(k, 3), "p#{k}w can't move from X#{k}/Y2 to X#{k}/Y3?"
    end
  end

  test 'each white pawn should move two squares from its starting position' do
    @white_pawns.each do |k, white_pawn|
      assert white_pawn.valid_move?(k, 4), "p#{k}w can't move from X#{k}/Y2 to X#{k}/Y4?"
    end
  end

  test 'each white pawn can not move backwards' do
    @white_pawns.each do |k, white_pawn|
      refute white_pawn.valid_move?(k, 1), "p#{k}w can move from X#{k}/Y2 to X#{k}/Y1?"
    end
  end

  # tests for black pawns

  test 'each black pawn may stay where it is' do
    @black_pawns.each do |k, black_pawn|
      assert black_pawn.valid_move?(k, 7), "p#{k}b can't stay in X#{k}/Y7?"
    end
  end

  test 'each black pawn should move one square from its starting position' do
    @black_pawns.each do |k, black_pawn|
      assert black_pawn.valid_move?(k, 6), "p#{k}b can't move from X#{k}/Y7 to X#{k}/Y6?"
    end
  end

  test 'each black pawn should move two squares from its starting position' do
    @black_pawns.each do |k, black_pawn|
      assert black_pawn.valid_move?(k, 5), "p#{k}b can't move from X#{k}/Y7 to X#{k}/Y5?"
    end
  end

  test 'each black pawn can not move backwards' do
    @black_pawns.each do |k, black_pawn|
      refute black_pawn.valid_move?(k, 8), "p#{k}b can move from X#{k}/Y7 to X#{k}/Y8?"
    end
  end
  
end
