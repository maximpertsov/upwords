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

  def test_equality
    assert_equal MoveUnit.new('a', 1, 2), @mu_a12
    assert_equal MoveUnit.new('b', 1, 3), @mu_b13
    assert_equal MoveUnit.new('c', 0, 2), @mu_c02
    assert_equal MoveUnit.new('d', 1, 2), @mu_d12
    assert_equal MoveUnit.new('e', 8, 8), @mu_e88
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

  def test_in_same_row?
    assert @mu_a12.in_same_row? @mu_b13
    refute @mu_a12.in_same_row? @mu_c02
  end

  def test_in_same_col?
    assert @mu_a12.in_same_col? @mu_c02
    refute @mu_a12.in_same_col? @mu_b13    
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

  def test_not_final_initially
    refute @mu_a12.final?
    refute @mu_b13.final?
    refute @mu_c02.final?
    refute @mu_d12.final?
    refute @mu_e88.final?
  end

  def test_can_make_final
    @mu_a12.finalize!
    @mu_c02.finalize!
    @mu_d12.finalize!

    assert @mu_a12.final?
    refute @mu_b13.final?
    assert @mu_c02.final?
    assert @mu_d12.final?
    refute @mu_e88.final?
  end
end
