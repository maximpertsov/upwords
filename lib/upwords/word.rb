module Upwords
  class Word
    
    # MIN_WORD_LENGTH = 2

    attr_reader :score

    def initialize(board, posns)
      @text = make_string(board, posns.uniq)
      @score = calc_score(board, posns.uniq)
    end

    def to_s
      @text.to_s
    end

    def to_str
      @text.to_str
    end

    private
    
    # A word's score is the sum of the tile heights of its letters
    # However, if all of a word's tile heights are exactly 1, then the score is double the word's length
    def calc_score(board, posns)
      stack_heights = posns.map{|row, col| board.stack_height(row, col)}
      score = stack_heights.inject(0) {|sum, h| sum + h}
      # Double word score if each letter space is only 1 tile high
      score * (stack_heights.all? {|h| h == 1} ? 2 : 1)
    end

    def make_string(board, posns)
      posns.map{|row, col| board.top_letter(row, col)}.join
    end

    end
  end
