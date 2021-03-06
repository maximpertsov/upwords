require 'test_helper'

class PlayerTest < Minitest::Test
  include Upwords
  
  class BasicPlayerTest < PlayerTest
    
    def setup
      @board = Board.new(10, 5)
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
  end

  class BoardPlayerTest < PlayerTest

    def setup
      @board = Board.new(10, 5)
      @p1 = Player.new("P1")
    end

    def test_can_play_letter
      @p1.take_letter('A')
      assert_equal [[0, 1], 'A'], @p1.play_letter(@board, 'A', 0, 1)
      assert_equal 'A', @board.top_letter(0, 1)
    end

    def test_cannot_play_letter_that_player_doesnt_have
      assert_raises(IllegalMove) {@p1.play_letter(@board, 'A', 0, 1)}
      assert_nil @board.top_letter(0, 1)
    end

    def test_can_take_from_board
      @board.play_letter('A', 0, 0)
      @p1.take_from(@board, 0, 0)

      assert_nil @board.top_letter(0, 0)
      assert_equal 'A', @p1.show_rack
    end

    def test_raise_error_if_no_letter_to_take_from_board
      assert_raises(IllegalMove) {@p1.take_from(@board, 0, 0)}
    end
  end
  
  class LetterBankPlayerTest < PlayerTest
    def setup
      @p1 = Player.new("P1", 7)
      @p2 = Player.new("P2", 4)
      @bank = LetterBank.new(('A'..'Z').to_a)
    end
   
    def test_can_refill_rack_to_capacity
      @p1.refill_rack(@bank)
      @p2.refill_rack(@bank)

      assert_equal '* * * * * * *', @p1.show_rack(true)
      assert_equal '* * * *', @p2.show_rack(true)
    end

    def test_cannot_refill_rack_beyond_bank_capacity
      @p1.refill_rack(LetterBank.new(['A']))                 
      assert_equal 'A', @p1.show_rack
    end

    def test_can_swap_letter
      @p1.take_letter('x')
      @p1.swap_letter('x', @bank)

      assert_includes('A'..'Z', @p1.show_rack)
      refute_equal 'x', @p1.show_rack
    end

    def test_cannot_swap_letter_with_empty_bank
      @p1.take_letter('x')
      empty_bank = LetterBank.new()
      
      assert_raises(IllegalMove) do
        @p1.swap_letter('x', empty_bank)
      end
      
      assert_equal 'x', @p1.show_rack
      assert empty_bank.empty?
    end
  end

  class CPUMovePlayerTest < PlayerTest
    
    def setup
      @board = Board.new(3, 5)
      @board.play_letter('C', 0, 0)
      @board.play_letter('A', 0, 1)
      @board.play_letter('T', 0, 2)

      @p1 = Player.new("P1")
      
      %w(D O G).each do |letter|
        @p1.take_letter(letter)
      end
    end

    def test_no_illegal_move_shapes
      legal_shapes = @p1.legal_move_shapes(@board) 

      illegal_shapes = [[[0,1],[0,2],[0,3]],
                        [[2,0]],
                        [[2,1]],
                        [[2,2]],
                        [[0,1],[0,3]]]

      illegal_shapes.each do |sh|
        refute_includes(legal_shapes, sh)
      end

      assert_includes(legal_shapes, [[0,0],[1,0],[2,0]])
      assert_includes(legal_shapes, [[1,0],[2,0]])
    end

    def test_legal_shape_letter_permutations
      legal_perms = Set.new(
        [[[[0, 2], "O"]],
         [[[0, 2], "G"]],
         [[[1, 2], "D"]],
         [[[1, 2], "O"]],
         [[[1, 2], "G"]],
         [[[0, 2], "D"], [[1, 2], "O"]],
         [[[0, 2], "D"], [[1, 2], "G"]],
         [[[0, 2], "O"], [[1, 2], "D"]],
         [[[0, 2], "O"], [[1, 2], "G"]],
         [[[0, 2], "G"], [[1, 2], "D"]],
         [[[0, 2], "G"], [[1, 2], "O"]],
         [[[1, 2], "D"], [[2, 2], "O"]],
         [[[1, 2], "D"], [[2, 2], "G"]],
         [[[1, 2], "O"], [[2, 2], "D"]],
         [[[1, 2], "O"], [[2, 2], "G"]],
         [[[1, 2], "G"], [[2, 2], "D"]],
         [[[1, 2], "G"], [[2, 2], "O"]],
         [[[0, 2], "D"], [[1, 2], "O"], [[2, 2], "G"]],
         [[[0, 2], "D"], [[1, 2], "G"], [[2, 2], "O"]],
         [[[0, 2], "O"], [[1, 2], "D"], [[2, 2], "G"]],
         [[[0, 2], "O"], [[1, 2], "G"], [[2, 2], "D"]],
         [[[0, 2], "G"], [[1, 2], "D"], [[2, 2], "O"]],
         [[[0, 2], "G"], [[1, 2], "O"], [[2, 2], "D"]]])

      legal_permutations = @p1.legal_move_shapes_letter_permutations(@board)
      
      legal_perms.each do |legal_perm|
        assert_includes(legal_permutations, legal_perm)
      end
    end

    def test_illegal_move_shapes_letter_permutations
      illegal_perms = Set.new(
        [[[[2, 0], "O"]],
         [[[2, 1], "G"]],
         [[[2, 2], "D"]],
         [[[2, 1], "D"], [[2, 2], "O"]],
         [[[2, 1], "D"], [[2, 2], "G"]],
         [[[2, 1], "O"], [[2, 2], "D"]],
         [[[2, 1], "O"], [[2, 2], "G"]],
         [[[2, 1], "G"], [[2, 2], "D"]],
         [[[2, 1], "G"], [[2, 2], "O"]],
         [[[2, 0], "D"], [[2, 1], "O"], [[2, 2], "G"]],
         [[[2, 0], "D"], [[2, 1], "G"], [[2, 2], "O"]],
         [[[2, 0], "O"], [[2, 1], "D"], [[2, 2], "G"]],
         [[[2, 0], "O"], [[2, 1], "G"], [[2, 2], "D"]],
         [[[2, 0], "G"], [[2, 1], "D"], [[2, 2], "O"]],
         [[[2, 0], "G"], [[2, 1], "O"], [[2, 2], "D"]]])

      legal_permutations = @p1.legal_move_shapes_letter_permutations(@board)
      
      illegal_perms.each do |illegal_perm|
        refute_includes(legal_permutations, illegal_perm)
      end
    end

    def test_cpu_move
      @dict = Dictionary.new(%w(CAT DOG COG))      
      assert_equal [[[1, 0], 'O'], [[2, 0], 'G']], @p1.cpu_move(@board, @dict, 1000, 6)
    end

  end
end
