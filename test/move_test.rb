require 'test_helper'

class MoveTest < Minitest::Test
  include Upwords

  def setup
    @move = Move.new
    @mu_a12 = MoveUnit.new('a', 1, 2)
    @mu_b13 = MoveUnit.new('b', 1, 3)
    @mu_c02 = MoveUnit.new('c', 0, 2)
    @mu_d12 = MoveUnit.new('d', 1, 2)
    @mu_e18 = MoveUnit.new('e', 1, 8)
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

  def test_letters
    assert_equal [], @move.letters

    @move.extend(@mu_a12)
    assert_equal ['a'], @move.letters

    @move.extend(@mu_b13)
    assert_equal ['a', 'b'], @move.letters

    @move.extend(@mu_c02)
    assert_equal ['a', 'b', 'c'], @move.letters
  end

  def test_positions
    assert_equal [], @move.positions

    @move.extend(@mu_a12)
    assert_equal [[1,2]], @move.positions

    @move.extend(@mu_b13)
    assert_equal [[1,2], [1,3]], @move.positions

    @move.extend(@mu_c02)
    assert_equal [[1,2], [1,3], [0,2]], @move.positions
  end
  
  def test_has_posn?
    refute @move.has_posn?(1,2)
    refute @move.has_posn?(1,3)
    
    @move.extend(@mu_a12)
    assert @move.has_posn?(1,2)
    refute @move.has_posn?(1,3)

    @move.extend(@mu_b13)
    assert @move.has_posn?(1,2)
    assert @move.has_posn?(1,3)
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

  def test_gaps
    @move.extend(@mu_a12)
    assert_equal [], @move.gaps
    
    @move.extend(@mu_b13)
    assert_equal [], @move.gaps

    @move.extend(@mu_e18)
    assert_equal [[1,4],[1,5],[1,6],[1,7]], @move.gaps
  end

  def test_connected?
    @move.extend(@mu_c02)   
    assert @move.connected?

    @move.extend(@mu_b13)  
    refute @move.connected?

    @move.extend(@mu_a12)
    assert @move.connected?

    @move.extend(@mu_e18)
    refute @move.connected?
  end
end
