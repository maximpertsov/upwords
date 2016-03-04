require 'test_helper'

class MoveTest < Minitest::Test
  include Upwords

  def setup
    @move = Move.new
  end

  def test_is_internally_connected_to_previously_played_moves?
    played_moves = Move.new

    [['C', 2, 4],
     ['A', 3, 4],
     ['B', 4, 4]].each do |ch,r,c|
      played_moves.add(ch, r, c)
    end

    @move.add('C', 3, 3)
    @move.add('B', 3, 5)

    assert @move.gaps_covered_by?(played_moves)
  end
  
  def test_not_touching_previously_played_moves
    played_moves = Move.new

    [['C', 2, 4],
     ['A', 3, 4],
     ['B', 4, 4]].each do |ch,r,c|
      played_moves.add(ch, r, c)
    end

    @move.add('C', 2, 0)
    @move.add('B', 3, 0)

    refute @move.touching?(played_moves)
  end

  def test_is_move_in_a_straight_line?
    @move.add('A', 0, 0)
    @move.add('B', 2, 0)
    @move.add('C', 4, 0)
    
    assert @move.straight_line?
  end

  def test_is_move_not_in_a_straight_line?
    @move.add('A', 0, 0)
    @move.add('B', 2, 0)
    @move.add('C', 0, 2)

    refute @move.straight_line?
  end

  def test_row_range
    @move.add('b', 1, 3)
    @move.add('e', 8, 8)
    @move.add('a', 1, 2)
    
    (1..8).each do |r|
      assert_includes @move.row_range, r
    end
  end

  def test_col_range
    @move.add('b', 1, 3)
    @move.add('e', 8, 8)
    @move.add('a', 1, 2)
    
    (2..8).each do |c|
      assert_includes @move.col_range, c
    end
  end

  def test_gaps
    @move.add('b', 1, 3)
    @move.add('c', 0, 2)
    
    [[0,3],[1,2]].each do |g|
      assert_includes @move.gaps, g
    end
  end

  def test_touching?
    @move.add('a', 1, 2)
    @move.add('b', 1, 3)

    other_move = Move.new
    other_move.add('c', 0, 2)
    
    assert @move.touching?(other_move)
  end

  def test_not_touching
    @move.add('b', 1, 3)

    other_move = Move.new
    other_move.add('c', 0, 2)
    other_move.add('e', 8, 8)
    
    refute @move.touching?(other_move)
  end

  def test_empty?
    assert @move.empty?
  end

  def test_can_add_move
    @move.add('a', 1, 2)
    assert @move.include?(1, 2)
  end

  def test_can_undo_last_move
    @move.add('a', 1, 2)
    @move.add('b', 3, 2)
    assert_equal [3,2], @move.undo
    assert_equal [1,2], @move.undo
  end

  def test_can_clear_moves
    @move.add('a', 1, 2)
    @move.add('b', 3, 2)
    @move.clear
    assert @move.empty?
  end
  
end

class MoveUnitTest < Minitest::Test
  include Upwords

  def setup
    @mu_a12 = MoveUnit.new('a', 1, 2)
    @mu_b13 = MoveUnit.new('b', 1, 3)
    @mu_c02 = MoveUnit.new('c', 0, 2)
    @mu_d12 = MoveUnit.new('d', 1, 2)
    @mu_e88 = MoveUnit.new('e', 8, 8)
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

  def test_same_row?
    assert @mu_a12.same_row? @mu_b13
    refute @mu_a12.same_row? @mu_c02
  end

  def test_same_col?
    assert @mu_a12.same_col? @mu_c02
    refute @mu_a12.same_col? @mu_b13    
  end

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
