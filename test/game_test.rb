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
  
  def test_all_possible_moves
    @player = Player.new("P1", 7)
    ('A'..'G').each {|l| @player.take_letter(l)}
    
    p " "
    p @game.ai_move(@player).size
  end

  def test_has_game_objects
    assert_kind_of(Board, @game.board)
    #assert_kind_of(LetterBank, @game.letter_bank)
  end

end
