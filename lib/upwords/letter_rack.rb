module Upwords
  class LetterRack
    
    attr_reader :capacity, :letters
    
    def initialize(capacity=7)
      @letters = []
      @capacity = capacity
    end

    def size
      @letters.size
    end

    def full?
      size == capacity
    end

    def empty?
      @letters.empty?
    end
        
    def has_letter?(letter)
      @letters.include? letter 
    end
    
    def add(letter)
      if full?
        raise IllegalMove, "Rack is full!"
      else
        @letters << letter        
      end
    end

    def remove(letter)
      if has_letter?(letter)
        @letters.delete_at(@letters.index(letter))
      else
        raise IllegalMove, "You don't have this letter!"
      end
    end

    def show
      @letters.join(' ')
    end

    def show_masked
      @letters.map {'*'}.join(' ')
    end
  end
end
