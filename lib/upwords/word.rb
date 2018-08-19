# frozen_string_literal: true

module Upwords
  class Word
    attr_reader :score, :length

    def initialize(posns, board)
      posns = posns.uniq if posns.is_a?(Array)

      @text = Word.make_string(board, posns)
      @score = Word.calc_score(board, posns)
      @length = @text.length
    end

    def to_s
      @text.to_s
    end

    def legal?(dict)
      dict.legal_word?(to_s)
    end

    # Check if this word end in `s`, and if removing
    # is the singular of this word
    def simple_plural?(dict)
      word = to_s
      return false unless word[-1] == 's'
      plural = word.chomp('s').pluralize
      dict.legal_word?(plural) && plural == word
    end

    # Calculate the score of word on board
    # NOTE: this method assumes that the word has already been played on the board
    #
    # A word's score is calculated as follows:
    # - Sum tile heights of all positions in word
    # - Multiple score by 2 if all positions in word are only 1 tile high
    # - Add two points for all 'Qu' tiles in word, if all positions in word are only 1 tile high (somewhat strange rule but whatever)
    # NOTE: players get a 20 point bonus for using all of their tiles in a move -> this logic is in a separate class
    def self.calc_score(board, posns)
      stack_heights = posns.map { |row, col| board.stack_height(row, col) }

      score = stack_heights.inject(0) { |sum, h| sum + h }

      # Double score if all letters are only 1 tile high
      if stack_heights.all? { |h| h == 1 }
        score *= 2

        # Add two points for each Qu (only all letters 1 tile high)
        score += (2 * posns.count { |posn| board.top_letter(*posn) == 'Qu' })
      end

      # TODO: Add 20 points if a player uses all of their entire rack in one turn. 7 is the maximum rack capacity
      score
    end

    def self.make_string(board, posns)
      posns.map { |row, col| board.top_letter(row, col) }.join
    end
  end
end
