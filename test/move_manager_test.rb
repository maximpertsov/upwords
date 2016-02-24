require 'test_helper'

class MoveManagerTest < Minitest::Test
  include Upwords

  class BasicMoveTest < MoveManagerTest
    def setup
      @player = Player.new("P1", 7)
      ('A'..'G').each {|l| @player.take_letter(l)}

      @board = Board.new(10)
      @moves = MoveManager.new(@board,
                               Dictionary.new(),
                               LetterBank.new())
    end

    def test_player_can_add_move
      @moves.add(@player, 'A', 0 , 0)
      assert @moves.include?([0, 0])

      assert_equal 'B C D E F G', @player.show_rack
    end

    def test_player_can_undo_a_move
      @moves.add(@player, 'A', 0, 0)
      @moves.add(@player, 'B', 1, 0)
      @moves.undo_last(@player)

      assert_equal 'C D E F G B', @player.show_rack
    end

    def test_player_can_undo_all_moves
      @moves.add(@player, 'A', 0, 0)
      @moves.add(@player, 'B', 1, 0)
      @moves.undo_all(@player)

      assert_equal 'C D E F G B A', @player.show_rack
    end

    def test_is_move_in_a_straight_line?
      @moves.add(@player, 'A', 0, 0)
      @moves.add(@player, 'B', 2, 0)
      @moves.add(@player, 'C', 4, 0)

      assert @moves.straight_line?
    end

    def test_is_move_not_in_a_straight_line?
      @moves.add(@player, 'A', 0, 0)
      @moves.add(@player, 'B', 2, 0)
      @moves.add(@player, 'C', 0, 2)

      refute @moves.straight_line?
    end

    # TODO: Refactor...
    def test_is_internally_connected!
      @board.play_letter('C', 2, 4)
      @board.play_letter('A', 3, 4)
      @board.play_letter('B', 4, 4)
      @moves.update_moves
      
      @moves.add(@player, 'C', 3, 3)
      @moves.add(@player, 'A', 3, 4)
      @moves.add(@player, 'B', 3, 5)

      assert @moves.connected_move?
    end
  end

  # class LetterBankMoveTest < MoveManagerTest
  #   def setup
  #     @p1 = Player.new("P1", [0,0], 7)
  #     @p2 = Player.new("P2", [0,0], 4)
  #     @bank = LetterBank.new(('A'..'Z').to_a)
  #   end

  #   def test_can_refill_rack_to_capacity
  #     @p1.refill_rack(@bank)
  #     @p2.refill_rack(@bank)

  #     assert_equal '* * * * * * *', @p1.show_hidden_rack
  #     assert_equal '* * * *', @p2.show_hidden_rack
  #   end

  #   def test_cannot_refill_rack_beyond_bank_capacity
  #     @p1.refill_rack(LetterBank.new(['A']))                 
  #     assert_equal 'A', @p1.show_rack
  #   end

  #   def test_can_swap_letter
  #     @p1.take_letter('x')
  #     @p1.swap_letter('x', @bank)

  #     assert_includes('A'..'Z', @p1.show_rack)
  #     refute_equal 'x', @p1.show_rack
  #   end

  #   def test_cannot_swap_letter_with_empty_bank
  #     @p1.take_letter('x')
  
  #     assert_raises(IllegalMove) do
  #       @p1.swap_letter('x', LetterBank.new())
  #     end
  
  #     assert_equal 'x', @p1.show_rack
  #   end
  # end
end
