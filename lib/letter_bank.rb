module Upwords
  class LetterBank

    # Letters available in 10 x 10 version of Upwords
    ALL_LETTERS = (["E"]*8 +
                   ["A", "I", "O"]*7 +
                   ["S"]*6 +
                   ["D", "L", "M", "N", "R", "T", "U"]*5 +
                   ["C"]*4 +
                   ["B", "F", "G", "H", "P"]*3 +
                   ["K", "W", "Y"]*2 +
                   ["J", "Qu", "V", "X", "Z"]*1)

    def initialize
      @bank = ALL_LETTERS.dup
    end

    # number of letters remaining in letter bank
    def letters_remaining
      @bank.size
    end

    def empty?
      letters_remaining == 0
    end

    # draw a random letter from the letter bank
    def draw
      @bank.delete_at(rand(@bank.size))
    end

    # put a letter back into the letter bank
    def deposit(letter)
      @bank << letter
    end  
  end
end
