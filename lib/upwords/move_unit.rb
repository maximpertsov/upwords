module Upwords
  class MoveUnit
    attr_reader :letter, :row, :col
    
    def initialize(letter, row, col)
      @letter = letter
      @row = row
      @col = col
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

    def next_to?(other_unit)
      if in_same_row?(other_unit)
        (self.col - other_unit.col).abs == 1
      elsif in_same_col?(other_unit)
        (self.row - other_unit.row).abs == 1
      else
        false
      end
    end
  end
end
