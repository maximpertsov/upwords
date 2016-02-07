require 'test_helper'

class BoardTest < Minitest::Test
  include Upwords

  def setup
    @board = Board.new
  end
  
  def test_create_empty_board
    b = Board.new
    assert (0..9).all? do |r|
      (0..9).all? {|c| b.top_letter(r, c).nil?} 
    end
  end

  def test_can_play_letters
    b = Board.new
    b.play_letter('m', 1, 3)
    b.play_letter('a', 2, 4)
    b.play_letter('x', 3, 5)

    my_word = [[1,3],[2,4],[3,5]].map {|r, c| b.top_letter(r, c)}.join('')
    assert_equal 'max', my_word
  end

  def test_can_stack_letters
    b = Board.new
    b.play_letter('m', 1, 3)
    b.play_letter('a', 2, 4)
    b.play_letter('i', 2, 4) # play another letter on same space   
    b.play_letter('x', 3, 5)

    my_word = [[1,3],[2,4],[3,5]].map {|r, c| b.top_letter(r, c)}.join('')
    assert_equal 'mix', my_word
  end

  def test_can_remove_letters
    b = Board.new
    
    # add some letters
    b.play_letter('m', 1, 3)
    b.play_letter('a', 2, 4)
    b.play_letter('i', 2, 4) # play another letter on same space
    b.play_letter('x', 3, 5)
    
    # remove some letters
    assert_equal b.remove_top_letter(2, 4), 'i'
    assert_equal b.remove_top_letter(3, 5), 'x'
                   
    my_word = [[1,3],[2,4],[3,5]].map {|r, c| b.top_letter(r, c)}.join('')
    assert_equal my_word, 'ma'
  end
end
