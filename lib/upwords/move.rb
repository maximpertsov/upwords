module Upwords
  class Move

    def initialize
      @move_units = Set.new
    end

    def covering_moves?(other_move)
      other_move.word_posns(2).any? do |posns|
        @move_units >= posns
      end
    end

    def union(other_move)
      union_set = @move_units.union(other_move.move_units)
      Move.build(union_set.map {|mu| [mu.row, mu.col, mu.letter]})
    end

    def words(min_size = 2)
      word_posns.map do |posns|
        posns.sort_by {|mu| mu.posn}.map {|mu| mu.letter}.join
      end
    end

    def word_posns(min_size = 2)
      row_words = @move_units.divide do |mu1, mu2| 
        (mu1.col - mu2.col).abs == 1 && mu1.row == mu2.row
      end
      
      col_words = @move_units.divide do |mu1, mu2| 
        (mu1.row - mu2.row).abs == 1 && mu1.col == mu2.col
      end

      (row_words + col_words).select {|set| set.size > min_size}.to_set
    end
        
    def gaps_covered_by?(other_move)
      (self.gaps - other_move.posns).empty?
    end

    def gaps
      square_range = (row_range.to_a).product(col_range.to_a)
      square_range.reject {|posn| (self.posns).include?(posn)}
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

    def add(row, col, letter = nil)
      @move_units << MoveUnit.new(row, col, letter)
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

    def posns
      @move_units.map {|mu| mu.posn}
    end

    def self.build(posns)
      new_move = Move.new
      posns.each {|row, col, letter| new_move.add(row, col, letter)}
      new_move
    end

    protected

    def touching_unit?(move_unit)
      @move_units.any? do |mu|
        mu.next_to?(move_unit) || mu.overlaps?(move_unit)
      end
    end

    def move_units
      @move_units
    end

  end
  
  class MoveUnit
    attr_reader :row, :col, :letter
    
    def initialize(row, col, letter = nil)
      @row = row
      @col = col
      @letter = letter.nil? ? " " : letter
    end
    
    def eql?(other_unit)
      overlaps?(other_unit)
    end
    
    def hash
      posn.hash
    end
   
    def overlaps?(other_unit)
      (self.row == other_unit.row) && (self.col == other_unit.col)
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
