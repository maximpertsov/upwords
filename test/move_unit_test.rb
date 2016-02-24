require 'test_helper'

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
  
  def test_all_same_row?
    assert MoveUnit.all_same_row? [@mu_b13, @mu_d12]
    refute MoveUnit.all_same_row? [@mu_b13, @mu_e88]
    assert MoveUnit.all_same_row? [@mu_a12]
    assert MoveUnit.all_same_row? []
  end

  def test_all_same_col?
    assert MoveUnit.all_same_col? [@mu_c02, @mu_a12]
    refute MoveUnit.all_same_col? [@mu_b13, @mu_c02]
    assert MoveUnit.all_same_col? [@mu_a12]
    assert MoveUnit.all_same_col? []
  end
  
  def test_row_range
    MoveUnit.row_range([@mu_b13,@mu_e88,@mu_a12]).each do |r|
      assert_includes (1..8), r
    end
  end

  def test_col_range
    MoveUnit.col_range([@mu_b13,@mu_e88,@mu_a12]).each do |c|
      assert_includes (2..8), c
    end
  end

  def test_skipped_rows
    MoveUnit.skipped_rows([@mu_b13,@mu_e88,@mu_a12]).each do |r|
      assert_includes (2..7), r
    end
  end

  def test_skipped_cols
    MoveUnit.skipped_cols([@mu_b13,@mu_e88,@mu_a12]).each do |c|
      assert_includes (4..7), c
    end

    mu_x15 = MoveUnit.new('x', 1, 5)
    MoveUnit.skipped_cols([mu_x15,@mu_e88,@mu_a12]).each do |c|
      assert_includes [3,4,6,7], c
    end
  end
end
