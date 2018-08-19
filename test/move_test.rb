# frozen_string_literal: true

require 'test_helper'

class MoveTest < Minitest::Test
  include Upwords

  def setup
    @move = Move.new([[[0, 0], 'c'], [[0, 1], 'a'], [[0, 2], 't']])
  end

  def test_check_if_position_exists
    assert @move.position?(0, 0)
    refute @move.position?(1, 1)
  end

  def test_get_letter
    assert_equal 'c', @move[0, 0]
    assert_equal 'a', @move[0, 1]
    assert_equal 't', @move[0, 2]
  end

  # Helper function: created board from [letter, row, col] array
  def make_board(moves)
    moves.each_with_object(Board.new(10, 5)) do |(letter, row, col), board|
      board.play_letter(letter, row, col)
    end
  end

  def test_can_play_to_board
    b = @move.play(Board.new(10, 5))

    assert_equal 'c', b.top_letter(0, 0)
    assert_equal 'a', b.top_letter(0, 1)
    assert_equal 't', b.top_letter(0, 2)
  end

  def test_can_remove_from_board
    b = @move.play(Board.new(10, 5))
    @move.remove_from(b)

    assert b.empty?
  end

  def test_cannot_remove_if_move_not_played
    b = Board.new(10, 5)
    b.play_letter('c', 0, 0)
    b.play_letter('a', 0, 1)

    assert_raises(IllegalMove) { @move.remove_from(b) }
  end

  def test_new_words
    b = make_board([['a', 1, 0], ['r', 2, 0], ['t', 3, 0]])

    new_words = @move.new_words(b).map(&:to_s)

    assert_equal 2, new_words.size
    assert_includes(new_words, 'cat')
    assert_includes(new_words, 'cart')
  end

  def test_illegal_words
    dict = Dictionary.new(['cart'])
    b = make_board([['a', 1, 0], ['r', 2, 0], ['t', 3, 0]])

    illegal_words = @move.new_illegal_words(b, dict).map(&:to_s)

    assert_equal 1, illegal_words.size
    assert_includes(illegal_words, 'cat')
  end
end
