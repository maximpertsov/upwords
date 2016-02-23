require 'test_helper'

class PlayerTest < Minitest::Test
  include Upwords
  
  class BasicPlayerTest < PlayerTest
    
    def setup
      @p1 = Player.new("P1")
      @p2 = Player.new("P2")
    end
    
    def test_can_get_name
      assert_equal "P1", @p1.name
      assert_equal "P2", @p2.name
    end

    def test_can_take_letter
      @p1.take_letter('A')
      assert_equal 'A', @p1.show_rack
    end

    def test_rack_full?
      refute @p1.rack_full?
    end

    def test_can_play_letter
      @p1.take_letter('A')
      assert_equal 'A', @p1.play_letter('A')
    end

    def test_cannot_play_letter_that_player_doesnt_have
      assert_raises(IllegalMove) { @p1.play_letter('A') }
    end

  end
end
