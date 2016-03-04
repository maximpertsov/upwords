require 'test_helper'

class MoveShapeTest < Minitest::Test
  include Upwords

  def setup
    @move = MoveShape.new
  end

  def test_build
    ms = MoveShape.build([[1,1],[1,2],[1,3]])

    assert_kind_of(MoveShape, ms)
    assert_equal 3, ms.size
  end

  # def test_union
  #   ms1 = MoveShape.build([[1,1],[1,2],[1,3]])
  #   ms2 = MoveShape.build([[1,2],[1,3],[1,4]])

  #   ms_union = ms1.union(ms2)

  #   assert_kind_of(MoveShape, ms_union)
  #   assert_equal 4, ms_union.size
  #   [[1,1],[1,2],[1,3],[1,4]].each do |r,c|
  #      assert ms_union.include?(r,c)
  #    end
  # end

  def test_gaps_covered_by_other_move?
    broken_move = MoveShape.build([[3, 3], [3, 5]])
    other_move = MoveShape.build([[2, 4], [3, 4], [4, 4]])

    assert broken_move.gaps_covered_by?(other_move)
  end
  
  def test_not_touching_previously_played_moves
    played_moves = MoveShape.new

    [[2, 4],
     [3, 4],
     [4, 4]].each do |r,c|
      played_moves.add(r, c)
    end

    @move.add(2, 0)
    @move.add(3, 0)

    refute @move.touching?(played_moves)
  end

  def test_is_move_in_a_straight_line?
    @move.add(0, 0)
    @move.add(2, 0)
    @move.add(4, 0)
    
    assert @move.straight_line?
  end

  def test_is_move_not_in_a_straight_line?
    @move.add(0, 0)
    @move.add(2, 0)
    @move.add(0, 2)

    refute @move.straight_line?
  end

  def test_row_range
    @move.add(1, 3)
    @move.add(8, 8)
    @move.add(1, 2)
    
    (1..8).each do |r|
      assert_includes @move.row_range, r
    end
  end

  def test_col_range
    @move.add(1, 3)
    @move.add(8, 8)
    @move.add(1, 2)
    
    (2..8).each do |c|
      assert_includes @move.col_range, c
    end
  end

  def test_gaps
    @move.add(1, 3)
    @move.add(0, 2)
    
    [[0,3],[1,2]].each do |g|
      assert_includes @move.gaps, g
    end
  end

  def test_touching?
    @move.add(1, 2)
    @move.add(1, 3)

    other_move = MoveShape.new
    other_move.add(0, 2)
    
    assert @move.touching?(other_move)
  end

  def test_not_touching
    @move.add(1, 3)

    other_move = MoveShape.new
    other_move.add(0, 2)
    other_move.add(8, 8)
    
    refute @move.touching?(other_move)
  end

  def test_empty?
    assert @move.empty?
  end

  def test_can_add_move
    @move.add(1, 2)
    assert @move.include?(1, 2)
  end
  
end

class MoveUnitTest < Minitest::Test
  include Upwords

  def setup
    @mu_a12 = MoveUnit.new(1, 2)
    @mu_b13 = MoveUnit.new(1, 3)
    @mu_c02 = MoveUnit.new(0, 2)
    @mu_d12 = MoveUnit.new(1, 2)
    @mu_e88 = MoveUnit.new(8, 8)
  end

  def test_hash_equality_aka_eql?
    s = Set.new
    assert_kind_of(Set, s.add?(@mu_a12))
    assert_kind_of(Set, s.add?(@mu_b13))
    assert_nil(s.add?(@mu_d12))
  end

  def test_posn
    assert_equal [1, 2], @mu_a12.posn
    assert_equal [1, 3], @mu_b13.posn
    assert_equal [0, 2], @mu_c02.posn
    assert_equal [1, 2], @mu_d12.posn
    assert_equal [8, 8], @mu_e88.posn
  end
  
  def test_overlaps?
    assert @mu_a12.overlaps? @mu_d12
    refute @mu_a12.overlaps? @mu_b13
  end

  # def test_same_row?
  #   assert @mu_a12.same_row? @mu_b13
  #   refute @mu_a12.same_row? @mu_c02
  # end

  # def test_same_col?
  #   assert @mu_a12.same_col? @mu_c02
  #   refute @mu_a12.same_col? @mu_b13    
  # end

  def test_orthogonal_spaces
    @mu_a12.orthogonal_spaces.each do |sp|
      assert_includes([[0,2],[2,2],[1,1],[1,3]], sp)
    end
  end

  def test_next_to?
    assert @mu_a12.next_to? @mu_b13
    assert @mu_a12.next_to? @mu_c02
    refute @mu_a12.next_to? @mu_e88
    refute @mu_a12.next_to? @mu_d12
  end

end
