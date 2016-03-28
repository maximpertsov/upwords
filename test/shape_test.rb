require 'test_helper'

class ShapeTest < Minitest::Test
  include Upwords

  def setup
    @move_shape = Shape.new
    @board = Board.new(10, 5)
  end
  
  class BasicShapeTest < ShapeTest
    def test_can_initiate_shape_from_position_list
      @move_shape = Shape.new([[1,1],[1,2, 'a'],[1,3]])
      assert_kind_of(Shape, @move_shape)
      assert_equal 3, @move_shape.size
    end

    def test_cannot_add_bad_positions
      bad_posns = [[1, 'a'], [1.0, 2], [1]]

      bad_posns.each do |posn|
        assert_raises(ArgumentError) {@move_shape.add(*posn)}
      end
      
      assert_raises(ArgumentError) do 
        Shape.new(bad_posns)
      end
    end

    def test_empty?
      assert @move_shape.empty?
    end
    
    def test_can_add_move
      @move_shape.add(1, 2)
      assert (@move_shape.positions).include? [1, 2]
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
  end

  class CoveringMovesShapeTest < ShapeTest
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
  end
  
  class NoGapsShapeTest < ShapeTest
    def test_gaps_covered_by_other_move?
      @move_shape.add(3,3)
      @move_shape.add(3,5)
      
      (2..4).each do |row|
        @board.play_letter('x', row, 4)
      end

      assert @move_shape.gaps_covered_by?(@board)
    end
  end

  class StraightLineShapeTest < ShapeTest
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
  end

  class TouchingShapeTest < ShapeTest
    def test_touching?
      @move_shape.add(1, 2)
      @move_shape.add(1, 3)

      @board.play_letter('x', 0, 2)

      assert @move_shape.touching?(@board)
    end

    def test_not_touching1
      @move_shape.add(1, 3)

      @board.play_letter('x', 0, 2)
      @board.play_letter('x', 8, 8)

      refute @move_shape.touching?(@board)
    end

    def test_not_touching2
      @move_shape.add(2, 0)
      @move_shape.add(3, 0)

      (2..4).each do |row|
        @board.play_letter('x', row, 4)
      end

      refute @move_shape.touching?(@board)
    end
  end

end
