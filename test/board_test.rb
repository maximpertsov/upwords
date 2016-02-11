require 'test_helper'
require 'set'

class BoardTest < Minitest::Test
  include Upwords

  class BasicBoardTest < BoardTest
    def setup
      @board = Board.new
    end
    
    def test_create_empty_board
      assert (0..9).all? do |r|
        (0..9).all? {|c| @board.top_letter(r, c).nil?} 
      end
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

      exp_empty = [[1,3], [2,4], [3,5]]
      act_empty = @board.nonempty_spaces
      
      assert_equal Set.new(exp_empty), Set.new(act_empty) 
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
                ["m", 5, 0], ["u", 5, 1]]
      
      @moves.each {|l, r, c| @board.play_letter(l, r, c)}
    end

    def test_get_words_on_columns
      assert_equal ["six"], @board.words_on_columns.map {|w| w.to_s}
    end

    def test_get_words_on_rows
      assert_equal ["max", "mu"], @board.words_on_rows.map {|w| w.to_s}
    end
  end
end
