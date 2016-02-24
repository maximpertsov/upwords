module Upwords
  class MoveUnit
    attr_reader :letter, :row, :col
    
    def initialize(letter, row, col)
      @letter = letter
      @row = row
      @col = col
    end
    
    # Letter does not factor into hash equality
    def eql?(other_unit)
      overlaps?(other_unit)
    end
    
    # Letter does not factor into hash equality
    def hash
      [row, col].hash
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

    # Class methods

    # def self.rows(move_units)
    #   move_units.map {|mu| mu.rows}
    # end

    # def self.cols(move_units)
    #   move_units.map {|mu| mu.cols}
    # end
    
    def self.all_same_row?(move_units)
      move_units.each_cons(2).all? {|m1, m2| m1.row == m2.row}
    end

    def self.all_same_col?(move_units)
      move_units.each_cons(2).all? {|m1, m2| m1.col == m2.col}
    end

    def self.straight_line?(move_units)
      self.all_same_row?(move_units) || self.all_same_col?(move_units)
    end

    def self.row_range(move_units)
      Range.new(*move_units.map {|mu| mu.row}.minmax)
    end
     
    def self.col_range(move_units)
      Range.new(*move_units.map {|mu| mu.col}.minmax)
    end

    def self.skipped_rows(move_units)
      move_units.reject do |r|
        self.row_range(move_units).include?(r.row)
      end
    end

    def self.skipped_cols(move_units)
      move_units.reject do |c|
        self.col_range(move_units).include?(c.col)
      end
    end

  end
end
