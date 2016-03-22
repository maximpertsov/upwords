require 'test_helper'

class PlayerManagerTest < Minitest::Test
  include Upwords
  
  def setup
    @pm = PlayerManager.new(2, "P1", "P2")
  end

  def test_current
    assert_equal "P1", @pm.current_player.name
  end

  def test_count
    assert_equal 2, @pm.player_count
  end

  def test_rotate!
    @pm.rotate!
    assert_equal "P2", @pm.current_player.name

    @pm.rotate!
    assert_equal "P1", @pm.current_player.name
  end

end
