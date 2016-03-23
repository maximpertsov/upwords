module Upwords
  class Shape

    attr_reader :positions
    
    def initialize(positions = [])
      @positions = positions.reduce(Set.new) {|set, (row, col)| set << [row, col]}
    end

    def covering_moves?(board)
      (board.word_positions).any? do |word_posns|
        positions >= word_posns
      end
    end
    
    def gaps_covered_by?(board) 
      nonempty_spaces = board.nonempty_spaces

      row_range.all? do |row|
        col_range.all? do |col|
          (@positions.include? [row, col]) || (nonempty_spaces.include? [row, col]) 
        end
      end
    end
       
    def touching?(board) 
      (board.nonempty_spaces).any? do |b_row, b_col|
        @positions.any? do |row, col|
          [(b_row - row).abs <= 1 && b_col == col,
           (b_col - col).abs <= 1 && b_row == row].any?
        end
      end
    end

    def straight_line?
      row_range.size == 1 || col_range.size == 1
    end

    def row_range
      Range.new(*@positions.map {|row, col| row}.minmax)
    end
    
    def col_range
      Range.new(*@positions.map {|row, col| col}.minmax)
    end

    def add(row, col)
      @positions.add [row, col]
    end

    alias_method :<<, :add

    def empty?
      @positions.empty?
    end

    def size
      @positions.size
    end

    def include? (row, col)
      @positions.include? [row, col]
    end

  end
end
