module Upwords
  class Move
    def initialize
      @move_units = []
      @uf = UnionFind.new
    end

    def size
      @move_units.size
    end

    def empty?
      @move_units.empty? && @uf.empty?
    end

    # clear move and return list of letters
    def pop_letters
      letters = @move_units.map {|mu| mu.letter}
      initialize
      letters
    end

    def extend(new_unit)
      if overlaps?(new_unit)
        raise IllegalMove, "You cannot stack on a space more than once in a single turn!"
      else
        connect_to_move(new_unit)
      end
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

    def connected?
      @uf.all_connected?
    end

    private

    def overlaps?(other_unit)
      @move_units.any? {|mu| mu.overlaps?(other_unit)}
    end

    def connect_to_move(new_unit)
      new_key = [new_unit.row, new_unit.col]
      @uf.add(new_key)
      
      @move_units.each do |mu|
        if new_unit.next_to?(mu)
          @uf.join([mu.row, mu.col], new_key)
        end
      end

      @move_units << new_unit
    end
    
  end
end
