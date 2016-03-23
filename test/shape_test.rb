require 'test_helper'

class ShapeTest < Minitest::Test
  include Upwords

  def setup
    @move_shape = Shape.new
  end

  def test_build
    ms = Shape.new([[1,1],[1,2, 'a'],[1,3]])
    assert_kind_of(Shape, ms)
    assert_equal 3, ms.size
  end

  def test_covered_word_positions
    board = [[2,4],[3,4],[4,4],
             [2,7],[3,7],[4,7]].reduce(Board.new(10,5)) do |b,(r,c)|
      b.play_letter('x', r, c)
      b
    end

    covering_move = Shape.new([[2,4],[3,4],[4,4]])
    not_covering_move = Shape.new([[2,4],[3,4]])

    assert covering_move.covering_moves?(board)
    refute not_covering_move.covering_moves?(board) 
  end

  def test_gaps_covered_by_other_move?
    broken_move = Shape.new([[3, 3], [3, 5]])
    board = [[2, 4], [3, 4], [4, 4]].reduce(Board.new(10, 5)) do |b, (row, col)|
      b.play_letter('x', row, col)
      b
    end
    assert broken_move.gaps_covered_by?(board)
  end

  def test_not_touching_previously_played_moves
    board = [[2, 4], [3, 4], [4, 4]].reduce(Board.new) do |b,(r,c)|
      b.play_letter('x', r, c)
      b
    end
    @move_shape.add(2, 0)
    @move_shape.add(3, 0)
    refute @move_shape.touching?(board)
  end

  def test_is_move_in_a_straight_line?
    @move_shape.add(0, 0)
    @move_shape.add(2, 0)
    @move_shape.add(4, 0)
    assert @move_shape.straight_line?
  end

  def test_is_move_not_in_a_straight_line?
    @move_shape.add(0, 0)
    @move_shape.add(2, 0)
    @move_shape.add(0, 2)
    refute @move_shape.straight_line?
  end

  def test_row_range
    @move_shape.add(1, 3)
    @move_shape.add(8, 8)
    @move_shape.add(1, 2)
    (1..8).each do |r|
      assert_includes @move_shape.row_range, r
    end
  end

  def test_col_range
    @move_shape.add(1, 3)
    @move_shape.add(8, 8)
    @move_shape.add(1, 2)
    (2..8).each do |c|
      assert_includes @move_shape.col_range, c
    end
  end

  def test_touching?
    @move_shape.add(1, 2)
    @move_shape.add(1, 3)
    board = Board.new(10, 5)
    board.play_letter('x', 0, 2)
    assert @move_shape.touching?(board)
  end

  def test_not_touching
    @move_shape.add(1, 3)
    board = Board.new(10, 5)
    board.play_letter('x', 0, 2)
    board.play_letter('x', 8, 8)
    refute @move_shape.touching?(board)
  end

  def test_empty?
    assert @move_shape.empty?
  end

  def test_can_add_move
    @move_shape.add(1, 2)
    assert (@move_shape.positions).include? [1, 2]
  end
end
