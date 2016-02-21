require 'test_helper'

class LetterRackTest < Minitest::Test
  include Upwords

  def setup
    @rack = LetterRack.new(7)
  end

  def test_init_capacity_is_7
    assert_equal 7, @rack.capacity
  end
end
