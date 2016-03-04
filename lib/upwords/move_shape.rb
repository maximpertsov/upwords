module Upwords
  class MoveShape

    def initialize
      @move_units = []
    end

    def gaps_covered_by?(other_move)
      (self.gaps - other_move.posns).empty?
    end

    def gaps
      posns = self.posns
      square_range.reject {|p| posns.include?(p)}
    end
    
    def square_range
      (row_range.to_a).product(col_range.to_a)
    end
        
    def row_range
      Range.new(*@move_units.map {|mu| mu.row}.minmax)
    end
    
    def col_range
      Range.new(*@move_units.map {|mu| mu.col}.minmax)
    end

    def touching?(other_move)
      @move_units.any? do |mu|
        other_move.touching_unit?(mu)
      end
    end

    def straight_line?
      row_range.size == 1 || col_range.size == 1
    end

    def add(row, col)
      @move_units << MoveUnit.new(row, col)
    end

    def empty?
      @move_units.empty?
    end

    def size
      @move_units.size
    end

    def include? (row, col)
      @move_units.any? do
        |m| m.overlaps?(MoveUnit.new(row, col))
      end
    end

    def undo
      (@move_units.pop).posn
    end

    def clear
      @move_units.clear
    end

    def posns
      @move_units.map {|mu| mu.posn}
    end

    def self.build(posns)
      new_move = MoveShape.new
      posns.each {|row, col| new_move.add(row, col)}
      new_move
    end

    protected

    def touching_unit?(move_unit)
      @move_units.any? do |mu|
        mu.next_to?(move_unit) || mu.overlaps?(move_unit)
      end
    end

  end
  
  class MoveUnit
    attr_reader :row, :col
    
    def initialize(row, col)
      @row = row
      @col = col
    end
    
    # Letter does not factor into hash equality
    def eql?(other_unit)
      overlaps?(other_unit)
    end
    
    # Letter does not factor into hash equality
    def hash
      posn.hash
    end
    
    def same_row?(other_unit)
      self.row == other_unit.row
    end

    def same_col?(other_unit)
      self.col == other_unit.col
    end

    def overlaps?(other_unit)
      same_row?(other_unit) && same_col?(other_unit)
    end

    def orthogonal_spaces
      [[row+1, col],[row-1, col],[row, col+1],[row, col-1]]
    end

    def next_to?(other_unit)
      orthogonal_spaces.include?(other_unit.posn)
    end

    def posn
      [self.row, self.col]
    end
  end
end
