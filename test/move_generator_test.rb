require 'test_helper'

class MoveGeneratorTest < Minitest::Test
  include Upwords

  def setup
    @moves = [
      Move.build([[0,1], [0,2]]),
      Move.build([[1,1], [0,2]]),
      Move.build([[1,1], [0,3], [3,3]])
    ]
  end

  def test_union_moves
    assert_equal 5, MoveGenerator.union_moves(@moves).size
  end

end
