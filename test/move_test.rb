require 'test_helper'

class MoveUnitTest < Minitest::Test
  include Upwords

  def setup
    @move1 = MoveUnit.new('a', 1, 2)
    @move2 = MoveUnit.new('b', 1, 3)
    @move3 = MoveUnit.new('c', 0, 2)
    @move4 = MoveUnit.new('d', 1, 2)
  end

  def test_overlap
    assert @move1.overlap? @move4
    refute @move1.overlap? @move2
  end

  def test_in_same_row?
    assert @move1.in_same_row? @move2
    refute @move1.in_same_row? @move3
  end

  def test_in_same_col?
    assert @move1.in_same_col? @move3
    refute @move1.in_same_col? @move2    
  end
end
