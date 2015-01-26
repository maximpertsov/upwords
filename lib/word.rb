module Upwords
  class Word
    
    MIN_WORD_LENGTH = 2

    attr_reader :score

    def initialize(board, posns)
      @board = board
      @posns = posns
      make_word
      calc_score
    end

    def to_s
      @text.to_s
    end

    def to_str
      @text.to_str
    end

    private
    
    def calc_score
      stack_heights = @posns.map{|row, col| @board.stack_height(row, col)}
      if stack_heights.map{|h| h == 1}.all?
        @score = stack_heights.size * 2
      else
        @score = stack_heights.inject(:+)
      end
    end

    def make_word
      @text = @posns.map{|row, col| @board.top_letter(row, col)}.join
    end

    end
  end
