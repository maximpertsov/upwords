module Upwords
  class LetterRack
    
    attr_reader :rack, :capacity
    
    def initialize(capacity=7) #letter_bank)
      #@bank = letter_bank
      @rack = []
      @capacity = capacity
    end
        
    def has_letter?(letter)
      @rack.include? letter 
    end
    
    def take_from(letter)
      letter = proper_case(letter)
      if !has_letter?(letter)
        raise IllegalMove, "You don't have this letter!"
      else
        @rack.delete_at(@rack.index(letter))
      end
    end
    
    # method assumes there is space on the rack for this letter
    ### WHAT IS THE BEST WAY TO ADDRESS THIS? (Assertion, Exception, etc?)
    def return_to(letter)
      raise Exception, "This is wrong!" unless @rack.compact.size < capacity ###
      @rack << letter 
    end

    # re-fill letter rack to capacity (or until letter bank is empty)
    def refill(letter_bank)
      @rack.compact! 
      while (@rack.size < capacity) && !letter_bank.empty? do
        @rack << letter_bank.draw 
      end
    end

    # swap letter in rack for a random letter from the bank
    def swap(letter, letter_bank)
      letter_bank.deposit(take_from(letter))
      @rack << letter_bank.draw
    end

    def show
      printed_rack = ""
      @rack.each{|letter| printed_rack += letter + " "}
      printed_rack
    end

    private

    def proper_case(letter)
      #convert letter to title case (qu or QU -> Qu)
      if letter.capitalize == 'Q'
        'Qu'
      else
        letter.capitalize
      end
    end

  end
end
