require 'test_helper'

class LetterRackTest < Minitest::Test
  include Upwords

  def setup
    @rack = LetterRack.new(4)
  end

  def test_size
    assert_equal 0, @rack.size
  end

  def test_capacity
    assert_equal 4, @rack.capacity
  end

  def test_full?
    (@rack.capacity).times do
      refute @rack.full?
      @rack.add('A')
    end

    assert @rack.full?
  end

  def test_can_add_letter
    refute @rack.has_letter? 'A'
    @rack.add 'A'
    assert @rack.has_letter? 'A'
  end

  def test_cannot_add_beyond_capacity
    (@rack.capacity).times { @rack.add('A') }
    assert_raises(IllegalMove) { @rack.add('A') }
  end

  def test_can_remove_letter
    @rack.add 'A'
    assert_equal 'A', @rack.remove('A')
    refute @rack.has_letter? 'A'
  end

  def test_cannot_remove_letter_that_is_not_in_rack
    assert_raises(IllegalMove) do
      @rack.remove('A')
    end
  end

  def test_can_show_rack_as_string
    ['A', 'B', 'C', 'Qu'].each {|l| @rack.add(l)}
    assert_equal 'A B C Qu', @rack.show
  end

  def test_can_show_rack_as_masked_string
    ['A', 'B', 'C', 'Qu'].each {|l| @rack.add(l)}
    assert_equal '* * * *', @rack.show_masked
  end
end
