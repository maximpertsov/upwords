module Upwords
  class LetterRack
    
    attr_reader :capacity
    
    def initialize(capacity=7)
      @rack = []
      @capacity = capacity
    end

    def size
      @rack.size
    end

    def full?
      size == capacity
    end
        
    def has_letter?(letter)
      @rack.include? letter 
    end
    
    def put_letter(letter)
      if full?
        raise IllegalMove, "Rack is full!"
      else
        @rack << letter        
      end
    end

    def get_letter(letter)
      if has_letter?(letter)
        @rack.delete_at(@rack.index(letter))
      else
        raise IllegalMove, "You don't have this letter!"
      end
    end

    def show
      @rack.join(' ')
    end

    def show_masked
      @rack.map {'*'}.join(' ')
    end
  end
end
