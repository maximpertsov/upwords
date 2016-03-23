require 'test_helper'

class MoveTest < Minitest::Test
  include Upwords

  def setup
    @move = Move.new([[0,0],[0,1],[0,2]], %w(c a t))
  end

  def test_get_letter_at_position
    assert_equal 'c', @move[0, 0]
    assert_equal 'a', @move[0, 1]
    assert_equal 't', @move[0, 2]
    assert_nil @move[0, 3]
  end
  
end
