class WordTest < Minitest::Test
  include Upwords

  def setup
    @board = Board.new

    @moves = [["m", 0, 1], ["a", 0, 2], ["x", 0, 3],        
              ["s", 1, 0],
              ["a", 2, 0],
              ["i", 2, 0], # stack 'i' on top of 'a'
              ["x", 3, 0]]
    
    @moves.each {|l, r, c| @board.play_letter(l, r, c)}

    # the word 'max'
    @word1 = Word.new(@board, @moves.map {|l, r, c| [r,c]}.select {|r,c| r == 0}.uniq)

    # the word 'six'
    @word2 = Word.new(@board, @moves.map {|l, r, c| [r,c]}.select {|r,c| c == 0}.uniq)
  end

  def test_score_with_bonus
    assert_equal 6, @word1.score
  end

  def test_score_no_bonus
    assert_equal 4, @word2.score
  end

end
