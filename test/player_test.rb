require 'test_helper'

class PlayerTest < Minitest::Test
  include Upwords
  
  def setup
    @game = Game.new("Max", "Jordan", display=false)
  end
end
