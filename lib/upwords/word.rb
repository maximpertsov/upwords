module Upwords
  class Word
    
    # MIN_WORD_LENGTH = 2

    attr_reader :score, :length

    def initialize(posns, board, dictionary)
      posns = posns.uniq if posns.is_a?(Array)
      @text = Word.make_string(board, posns)
      @score = Word.calc_score(board, posns)
      @length = @text.length
      @dict = dictionary
    end

    def to_s
      @text.to_s
    end

    def legal?
      @dict.legal_word?(self.to_s)
    end
    
    # A word's score is the sum of the tile heights of its letters
    # However, if all of a word's tile heights are exactly 1, then the score is double the word's length
    #          also add two points for each 'Qu' if all words are 1 tile high
    # Add 20 points if a player uses all their letters to form a word (TODO)
    def self.calc_score(board, posns)
      stack_heights = posns.map{|row, col| board.stack_height(row, col)}

      score = stack_heights.inject(0) {|sum, h| sum + h}

      # Double score if all letters are only 1 tile high
      if stack_heights.all? {|h| h == 1}
        score *= 2
        
        # Add two points for each Qu (only all letters 1 tile high)
        score += (2 * posns.count {|posn| board.top_letter(*posn) == 'Qu'})  
      end

      # TODO: Add 20 points if a player uses all of their entire rack in one turn. 7 is the maximum rack capacity
      score
    end

    def self.make_string(board, posns)
      posns.map{|row, col| board.top_letter(row, col)}.join
    end

    end
  end
