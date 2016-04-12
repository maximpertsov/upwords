require 'test_helper'

class GameTest < Minitest::Test
  include Upwords
  
  def setup
    @game = Game.new(display=false)
    @game.add_player("Max")
    @game.add_player("Jordan")
  end

  def teardown
    @game.exit_game(false) if @game.running?
  end

  def test_has_game_objects
    assert_kind_of(Board, @game.board)
  end

  def test_can_play_letter_at_cursor_posn
    @game.current_player.take_letter("C")
    @game.play_letter("C")
    assert_equal "C", @game.board.top_letter(*@game.cursor.posn)
  end

  def test_can_play_letter_at_given_posn
    @game.current_player.take_letter("C")
    @game.play_letter("C", 4, 5)
    assert_equal "C", @game.board.top_letter(4, 5)
  end

end
