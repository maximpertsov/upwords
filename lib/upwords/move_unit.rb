module Upwords
  class MoveUnit
    attr_reader :letter, :row, :col
    
    def initialize(letter, row, col)
      @letter = letter
      @row = row
      @col = col
      @final = false
    end

    def ==(other_unit)
      overlaps?(other_unit) && self.letter == other_unit.letter
    end
    
    def same_row?(other_unit)
      self.row == other_unit.row
    end

    def all_same_row?(other_units)
      other_units.all? {|mu| mu.same_row? self}
    end

    def same_col?(other_unit)
      self.col == other_unit.col
    end

    def all_same_col?(other_units)
      other_units.all? {|mu| mu.same_col? self}
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

    def final?
      @final
    end

    def finalize!
      @final = true
    end
  end
end
