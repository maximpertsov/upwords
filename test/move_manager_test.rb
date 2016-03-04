require 'test_helper'

class MoveManagerTest < Minitest::Test
  include Upwords

  class BasicMoveTest < MoveManagerTest
    def setup
      @player = Player.new("P1", 7)
      ('A'..'G').each {|l| @player.take_letter(l)}

      @board = Board.new(10)
      @moves = MoveManager.new(@board, Dictionary.new(['BAD']))
    end

    def test_player_can_add_move
      @moves.add(@player, 'A', 0 , 0)
      #assert @moves.include?([0, 0])

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

    def test_player_can_submit_move
      @moves.add(@player, 'B', 4, 4)
      @moves.add(@player, 'A', 4, 5)
      @moves.add(@player, 'D', 4, 6)
      @moves.submit(@player)

      assert_equal 6, @player.score
      # TODO: expand test
    end

    def test_cannot_stack_letter_on_same_letter
      @board.play_letter('C', 2, 4)
      @board.play_letter('A', 3, 4)
      @board.play_letter('B', 4, 4)
      @moves.finalize_pending_move
      
      assert_raises(IllegalMove) { @moves.add(@player, 'A', 3, 4) }
 
    end

    def test_pending_words
      @board.play_letter('P', 2, 8)
      @board.play_letter('O', 3, 8)
      @board.play_letter('O', 4, 8)

      #@moves.finalize_pending_move
      
      @moves.add(@player, 'C', 2, 4)
      @moves.add(@player, 'A', 3, 4)
      @moves.add(@player, 'B', 4, 4)

      @moves.add(@player, 'F', 3, 3)
      @moves.add(@player, 'D', 3, 5)

      expected = ['CAB', 'FAD']
      actual = @moves.pending_words.map {|w| w.to_s}
        
      assert_equal Set.new(expected), Set.new(actual) 
    end
    
    def test_covered_words
      @board.play_letter('P', 2, 4)
      @board.play_letter('O', 3, 4)
      @board.play_letter('O', 4, 4)

      @board.play_letter('Y', 2, 7)
      @board.play_letter('U', 3, 7)
      @board.play_letter('P', 4, 7)
      
      #@moves.finalize_pending_move
      
      @moves.add(@player, 'C', 2, 4)
      @moves.add(@player, 'A', 3, 4)
      @moves.add(@player, 'B', 4, 4)

      expected = ['POO']
      actual = @moves.covered_words.map {|w| w.to_s}
        
      assert_equal Set.new(expected), Set.new(actual) 
    end

    def test_cannot_play_single_letter_for_first_move
      @moves = MoveManager.new(@board, Dictionary.new(['A']))
      @moves.add(@player, 'A', 4, 4)
      assert_raises(IllegalMove) {@moves.submit(@player)}
    end
    
    def test_must_play_in_middle_2x2_square_for_first_move
      @moves = MoveManager.new(@board, Dictionary.new(['AB']))
      @moves.add(@player, 'A', 3, 3)
      @moves.add(@player, 'B', 3, 4)
      assert_raises(IllegalMove) {@moves.submit(@player)}

      @moves.undo_all(@player)

      @moves.add(@player, 'A', 4, 5)
      @moves.add(@player, 'B', 4, 6)
      assert @moves.legal?
    end
  end
end
