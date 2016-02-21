require 'test_helper'

class MoveManagerTest < Minitest::Test
  include Upwords

  def setup
    @board = Board.new
    @mgr = MoveManager.new
  end

  # def test_no_pending_move_empty
  #   refute @mgr.pending_move?
  # end

  # def test_can_add_move
  #   @board.add_move('a', 0, 0)
  #   assert @board.pending_move?
  # end

end
