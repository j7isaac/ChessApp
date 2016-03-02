require 'test_helper'

class PawnTest < ActiveSupport::TestCase
  
  def setup
    game = games(:one)
    
    @white_pawns = {}
    @black_pawns = {}

    (1..8).each do |i|
      @white_pawns[i] = Pawn.create(game: game, x_coordinate: 7, y_coordinate: i, color: 'white')
      @black_pawns[i] = Pawn.create(game: game, x_coordinate: 2, y_coordinate: i, color: 'black')
    end
  end
  
# tests for white pawns
  
  test "each white pawn may stay where it is" do
    @white_pawns.each do |k, white_pawn|
      assert white_pawn.valid_move?(7, k), "p#{k}w can't stay in X7/Y#{k}?"
    end
  end

  test "each white pawn should move one square from its starting position" do
    @white_pawns.each do |k, white_pawn|
      assert white_pawn.valid_move?(6, k), "p#{k}w can't move from X7/Y#{k} to X6/Y#{k}?"
    end
  end
  
  test "each white pawn should move two squares from its starting position" do
    @white_pawns.each do |k, white_pawn|
      assert white_pawn.valid_move?(5, k), "p#{k}w can't move from X7/Y#{k} to X5/Y#{k}?"
    end
  end

  test "each white pawn can not move backwards" do
    @white_pawns.each do |k, white_pawn|
      refute white_pawn.valid_move?(8, k), "p#{k}w can move from X7/Y#{k} to X8/Y#{k}?"
    end
  end

# tests for black pawns

  test "each black pawn may stay where it is" do
    @black_pawns.each do |k, black_pawn|
      assert black_pawn.valid_move?(2, k), "p#{k}b can't stay in X2/Y#{k}?"
    end
  end
  
  test "each black pawn should move one square from its starting position" do
    @black_pawns.each do |k, black_pawn|
      assert black_pawn.valid_move?(3, k), "p#{k}b can't move from X2/Y#{k} to X3/Y#{k}?"
    end
  end
  
  test "each black pawn should move two squares from its starting position" do
    @black_pawns.each do |k, black_pawn|
      assert black_pawn.valid_move?(4, k), "p#{k}b can't move from X2/Y#{k} to X4/Y#{k}?"
    end
  end

  test "each black pawn can not move backwards" do
    @black_pawns.each do |k, black_pawn|
      refute black_pawn.valid_move?(1, k), "p#{k}b can move from X2/Y#{k} to X1/Y#{k}?"
    end
  end

end
