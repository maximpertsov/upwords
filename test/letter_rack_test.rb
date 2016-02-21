require 'test_helper'

class LetterRackTest < Minitest::Test
  include Upwords

  def setup
    @rack = LetterRack.new(7)
  end

  def test_size
    assert_equal 0, @rack.size
  end

  def test_full?
    (@rack.capacity).times do
      refute @rack.full?
      @rack.put_letter('A')
    end

    assert @rack.full?
  end

  def test_can_put_letter
    refute @rack.has_letter? 'A'
    @rack.put_letter 'A'
    assert @rack.has_letter? 'A'
  end

  def test_cannot_put_beyond_capacity
    (@rack.capacity).times { @rack.put_letter('A') }
    assert_raises(IllegalMove) { @rack.put_letter('A') }
  end

  def test_can_get_letter
    @rack.put_letter 'A'
    assert_equal 'A', @rack.get_letter('A')
    refute @rack.has_letter? 'A'
  end

  def test_cannot_get_letter_that_is_not_in_rack
    assert_raises(IllegalMove) do
      @rack.get_letter('A')
    end
  end

  def test_can_show_rack_as_string
    ['A', 'B', 'C', 'Qu'].each {|l| @rack.put_letter(l)}
    assert_equal 'A B C Qu', @rack.show
  end

  def test_can_show_rack_as_masked_string
    ['A', 'B', 'C', 'Qu'].each {|l| @rack.put_letter(l)}
    assert_equal '* * * *', @rack.show_masked
  end
end
