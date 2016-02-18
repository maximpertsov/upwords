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

    def overlap?(other_unit)
      in_same_row?(other_unit) && in_same_col?(other_unit)
    end
  end
end
