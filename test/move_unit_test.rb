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

  def test_next_to?
    assert @mu_a12.next_to? @mu_b13
    assert @mu_a12.next_to? @mu_c02
    refute @mu_a12.next_to? @mu_e88
    refute @mu_a12.next_to? @mu_d12
  end
end
