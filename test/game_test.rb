require 'test_helper'

class GameTest < Minitest::Test
  include Upwords
  
  def setup
    @game = Game.new("Max", "Jordan", display=false)
  end

  def teardown
    @game.exit_game(false) if @game.running?
  end

  def test_has_game_objects
    assert_kind_of(Board, @game.board)
    assert_kind_of(LetterBank, @game.letter_bank)
  end

end
