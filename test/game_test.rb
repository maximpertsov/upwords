require 'test_helper'

class GameTest < Minitest::Test
  include Upwords
  
  def setup
    @game = Game.new("Max", "Jordan")
  end

  def teardown
    @game.exit_game
  end
end
