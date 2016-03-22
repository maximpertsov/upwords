module Upwords
  class LetterBank

    def initialize(letters=[])
      @bank = letters.dup
    end

    def empty?
      @bank.empty?
    end

    def draw
      unless self.empty?
        @bank.delete_at(rand(@bank.size))
      end
    end

    def deposit(letter)
      @bank << letter
    end  
  end
end
