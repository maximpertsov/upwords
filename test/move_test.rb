require 'test_helper'

class MoveTest < Minitest::Test
  include Upwords

  def setup
    @move = Move.new
    @mu_a12 = MoveUnit.new('a', 1, 2)
    @mu_b13 = MoveUnit.new('b', 1, 3)
    @mu_c02 = MoveUnit.new('c', 0, 2)
    @mu_d12 = MoveUnit.new('d', 1, 2)
    @mu_e88 = MoveUnit.new('e', 8, 8)
  end

  def test_empty?
    assert @move.empty?
    @move.extend(@mu_a12)
    refute @move.empty?
  end

  def test_size
    assert_equal(0, @move.size)

    [@mu_a12, @mu_b13, @mu_c02].each_with_index do |mu, i|
      @move.extend(mu)
      assert_equal(i+1, @move.size)
    end
  end

  def test_pop_letters
    @move.extend(@mu_a12)
    @move.extend(@mu_b13)
    @move.extend(@mu_c02)
    refute @move.empty?

    assert_equal(['a', 'b', 'c'], @move.pop_letters)
    assert @move.empty?
  end
  
  def test_extend
    @move.extend(@mu_a12)
    @move.extend(@mu_b13)
    @move.extend(@mu_c02)
    
    assert_raises(IllegalMove) { @move.extend(@mu_d12) }
  end

  def test_in_one_row?
    assert @move.in_one_row?
    
    @move.extend(@mu_a12)
    assert @move.in_one_row?
    
    @move.extend(@mu_b13)
    assert @move.in_one_row?

    @move.extend(@mu_c02)
    refute @move.in_one_row?
  end

  def test_in_one_col?
    assert @move.in_one_col?
    
    @move.extend(@mu_a12)
    assert @move.in_one_col?

    @move.extend(@mu_c02)   
    assert @move.in_one_col?

    @move.extend(@mu_b13)
    refute @move.in_one_col?    
  end

  def test_connected?
    @move.extend(@mu_c02)   
    assert @move.connected?

    @move.extend(@mu_b13)  
    refute @move.connected?

    @move.extend(@mu_a12)
    assert @move.connected?

    @move.extend(@mu_e88)
    refute @move.connected?
  end
end
