module Upwords
  class MoveUnit
    attr_reader :letter, :row, :col
    
    def initialize(letter, row, col)
      @letter = letter
      @row = row
      @col = col
      @final = false
    end

    def in_same_row?(other_unit)
      self.row == other_unit.row
    end

    def in_same_col?(other_unit)
      self.col == other_unit.col
    end

    def overlaps?(other_unit)
      in_same_row?(other_unit) && in_same_col?(other_unit)
    end

    def orthogonal_spaces
      [[row+1, col],[row-1, col],[row, col+1],[row, col-1]]
    end

    def next_to?(other_unit)
      orthogonal_spaces.include? [other_unit.row, other_unit.col]
    end

    def final?
      @final
    end

    def finalize!
      @final = true
    end
  end
end
