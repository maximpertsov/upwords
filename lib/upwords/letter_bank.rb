module Upwords
  class LetterBank

    def initialize(letters)
      @bank = letters.dup
    end

    def empty?
      @bank.empty?
    end

    def draw
      @bank.delete_at(rand(@bank.size))
    end

    def deposit(letter)
      @bank << letter
    end  
  end
end
