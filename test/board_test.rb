require 'test_helper'

class BoardTest < Minitest::Test
  include Upwords

  class BasicBoardTest < BoardTest
    def setup
      @board = Board.new(10)
    end
    
    def test_initially_empty_board
      assert @board.empty?
    end

    def test_empty_after_play_and_remove
      @board.play_letter('x', 0, 0)
      @board.remove_top_letter(0, 0)
      assert @board.empty?
    end

    def test_not_empty
      @board.play_letter('x', 0, 0)
      refute @board.empty?
    end

    def test_can_play_letters
      @board.play_letter('m', 1, 3)
      @board.play_letter('a', 2, 4)
      @board.play_letter('x', 3, 5)

      my_word = [[1,3],[2,4],[3,5]].map {|r, c| @board.top_letter(r, c)}.join('')
      assert_equal 'max', my_word
    end

    def test_can_stack_letters
      @board.play_letter('m', 1, 3)
      @board.play_letter('a', 2, 4)
      @board.play_letter('i', 2, 4) # play another letter on same space   
      @board.play_letter('x', 3, 5)

      my_word = [[1,3],[2,4],[3,5]].map {|r, c| @board.top_letter(r, c)}.join('')
      assert_equal 'mix', my_word
    end

    def test_can_remove_letters
      # add some letters
      @board.play_letter('m', 1, 3)
      @board.play_letter('a', 2, 4)
      @board.play_letter('i', 2, 4) # play another letter on same space
      @board.play_letter('x', 3, 5)
      
      # remove some letters
      assert_equal @board.remove_top_letter(2, 4), 'i'
      assert_equal @board.remove_top_letter(3, 5), 'x'
      
      my_word = [[1,3],[2,4],[3,5]].map {|r, c| @board.top_letter(r, c)}.join('')
      assert_equal 'ma', my_word
    end

    def test_can_get_stack_height
      # add some letters
      @board.play_letter('m', 1, 3)
      @board.play_letter('a', 2, 4)
      @board.play_letter('i', 2, 4) # play another letter on same space
      @board.play_letter('x', 3, 5)
      
      stack_heights = [[1,3],[2,4],[3,5]].map {|r, c| @board.stack_height(r, c)}

      assert_equal [1,2,1], stack_heights
    end

    def test_can_get_number_of_rows
      assert_equal 10, @board.num_rows
    end

    def test_can_get_number_of_columns
      assert_equal 10, @board.num_columns
    end
    
    def test_can_get_nonempty_spaces
      @board.play_letter('m', 1, 3)
      @board.play_letter('a', 2, 4)
      @board.play_letter('x', 3, 5)

      expected = [[1,3], [2,4], [3,5]]
      actual = @board.nonempty_spaces
      
      assert_equal Set.new(expected), actual 
    end

    def test_can_play_letter
      assert @board.can_play_letter?('a', 0, 0)
    end

    def test_cannot_play_letter_if_stack_full
      ('a'..'e').map {|l| [[0,0], l]}.reduce(@board) do |b, (posn, letter)|
        b.play_letter(letter, *posn)
        b
      end
      
      refute @board.can_play_letter?('a', 0, 0)
      
      assert_raises(IllegalMove) do 
        @board.can_play_letter?('a', 0, 0, raise_exception=true)
      end
    end

    def test_cannot_play_on_top_of_same_letter
      @board.play_letter('a', 0, 0)
      
      assert @board.can_play_letter?('b', 0, 0)
      refute @board.can_play_letter?('a', 0, 0)
      
      assert_raises(IllegalMove) do 
        @board.can_play_letter?('a', 0, 0, raise_exception=true)
      end
    end

  end

  class BoardMoveTest <BoardTest
    def setup
      @board = Board.new(10, 5)
      @move = Move.new([[[0,0], 'c'], [[0,1], 'a'], [[0,2], 't']])
    end

    def test_play_move
      @board.play_move(@move)
    
      assert_equal 'c', @board.top_letter(0, 0)
      assert_equal 'a', @board.top_letter(0, 1)
      assert_equal 't', @board.top_letter(0, 2)
    end

    def test_undo_move
      @board.play_move(@move)
      @board.undo_move(@move)
      
      refute @board.nonempty_space?(0, 0)
      refute @board.nonempty_space?(0, 1)
      refute @board.nonempty_space?(0, 2)
    end


    def test_cannot_undo_move_if_not_played
      diff_move = Move.new([[[0,0], 'd'], [[0,1], 'o'], [[0,2], 'g']])
      @board.play_move(diff_move)
      assert_raises(IllegalMove) {@board.undo_move(@move)}
    end

    def test_build_from_moves
      diff_move = Move.new([[[0,1], 'o'], [[0,2], 'g']])

      new_board = Board.build([@move, diff_move], 10, 5)
            
      assert_equal 'c', new_board.top_letter(0, 0)
      assert_equal 'o', new_board.top_letter(0, 1)
      assert_equal 'g', new_board.top_letter(0, 2)

      assert_equal 1, new_board.stack_height(0, 0)
      assert_equal 2, new_board.stack_height(0, 1)
      assert_equal 2, new_board.stack_height(0, 2)
    end

  end

  class BoardWordTest < BoardTest
    def setup
      @board = Board.new

      @moves = [["m", 0, 1], ["a", 0, 2], ["x", 0, 3],
                ["s", 1, 0],
                ["a", 2, 0],
                ["i", 2, 0], # stack 'i' on top of 'a'
                ["x", 3, 0],
                ["m", 5, 0], ["u", 5, 1],
                ["z", 9, 9]] # not long enough to be a word
      
      @moves.each {|l, r, c| @board.play_letter(l, r, c)}
    end

    def test_get_words_on_board
      expected = [
        [[1,0],[2,0],[3,0]], # "six"
        [[0,1],[0,2],[0,3]], # "max"
        [[5,0],[5,1]]        # "mu"
      ].map {|posns| SortedSet.new(posns)}
       
      actual = @board.word_positions
      
      assert_equal Set.new(expected), Set.new(actual)
    end
  end

end
