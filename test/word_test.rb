# frozen_string_literal: true

class WordTest < Minitest::Test
  include Upwords

  def setup
    @board = Board.new
    @dict = Dictionary.new(%w[cat cats])
    cat = [['c', 0, 1], ['a', 0, 2], ['t', 0, 3]]
    slx = [
      ['s', 1, 0],
      ['a', 2, 0],
      ['l', 2, 0], # stack 'l' on top of 'a'
      ['x', 3, 0]
    ]

    @moves = cat + slx
    @moves.each { |l, r, c| @board.play_letter(l, r, c) }

    @posns = @moves.map { |_l, r, c| [r, c] }
    # the word 'cat'
    @word1 = Word.new(@posns.select { |r, _c| r.zero? }, @board)
    # the word 'slx'
    @word2 = Word.new(@posns.select { |_r, c| c.zero? }, @board)
  end

  def test_score_with_bonus
    assert_equal 6, @word1.score
  end

  def test_score_no_bonus
    assert_equal 4, @word2.score
  end

  def test_legal_word
    assert @word1.legal?(@dict)
  end

  def test_illegal_word
    refute @word2.legal?(@dict)
  end

  def test_simple_plural
    # Try to make 'cats' by adding an 's'
    posn, _l = @board.play_letter('s', 0, 4)
    @posns << posn
    plural = Word.new(@posns.select { |r, _c| r.zero? }, @board)
    assert plural.simple_plural?(@dict)
  end
end
