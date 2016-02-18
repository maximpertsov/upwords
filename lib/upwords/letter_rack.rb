module Upwords
  class LetterRack
    
    attr_reader :rack
    
    def initialize(letter_bank)
      @bank = letter_bank
      @rack = []
      refill
    end
    
    # maximum number of letters that fit in each player's rack
    def capacity
      7
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
    def refill
      @rack.compact! 
      while (@rack.size < capacity) && !@bank.empty? do
        @rack << @bank.draw 
      end
    end

    # swap letter in rack for a random letter from the bank
    def swap(letter)
      @bank.deposit(take_from(letter))
      @rack << @bank.draw
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
