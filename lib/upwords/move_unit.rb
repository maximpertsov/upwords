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

    def self.square_range(move_units)
      row_range = self.row_range(move_units) 
      col_range = self.col_range(move_units)

      (row_range.to_a).product(col_range.to_a)
    end
    
    def self.gaps(move_units)
      posns = move_units.map {|mu| mu.posn}
      self.square_range(move_units).reject do |posn|
        posns.include?(posn)
      end
    end
      
    def self.row_range(move_units)
      Range.new(*move_units.map {|mu| mu.row}.minmax)
    end
     
    def self.col_range(move_units)
      Range.new(*move_units.map {|mu| mu.col}.minmax)
    end

    def self.touching?(moves1, moves2)
      moves1.any? do |mu1|
        moves2.any? do |mu2|
          mu1.next_to?(mu2) || mu1.overlaps?(mu2)
        end
      end
    end
    
    # def self.all_same_row?(move_units)
    #   move_units.each_cons(2).all? {|m1, m2| m1.row == m2.row}
    # end

    # def self.all_same_col?(move_units)
    #   move_units.each_cons(2).all? {|m1, m2| m1.col == m2.col}
    # end

    def self.straight_line?(move_units)
      self.row_range(move_units).size == 1 || self.col_range(move_units).size == 1
      #self.all_same_row?(move_units) || self.all_same_col?(move_units)
    end
  end
end
