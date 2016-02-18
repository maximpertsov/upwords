module Upwords
  class LetterBank

    def initialize(letters)
      @bank = letters.dup #ALL_LETTERS.dup
    end

    # def size
    #   #letters_remaining
    #   @bank.size
    # end

    def empty?
      @bank.empty?
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
