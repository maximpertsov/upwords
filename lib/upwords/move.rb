module Upwords
  class Move
    def initialize
      @move_units = []
    end

    def size
      @move_units.size
    end

    def empty?
      @move_units.empty?
    end

    def extend(new_unit)
      if overlap?(new_unit)
        raise IllegalMove, "You cannot stack on a space more than once in a single turn!"
      else
        @move_units << new_unit
      end
    end
    
    def overlap?(other_unit)
      @move_units.any? {|mu| mu.overlap?(other_unit)}
    end

    def in_one_row?
      size < 2 || @move_units.each_cons(2).all? do |mu1, mu2|
        mu1.in_same_row? mu2 
      end
    end
    
    def in_one_col?
      size < 2 || @move_units.each_cons(2).all? do |mu1, mu2|
        mu1.in_same_col? mu2
      end
    end
  end
end
