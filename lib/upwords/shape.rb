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
      row_range.all? do |row|
        col_range.all? do |col|
          @positions.include?([row, col]) || board.nonempty_space?(row, col)
        end
      end
    end
       
    def touching?(board) 
      @positions.any? do |row, col|
        # Are any positions overlapping or adjacent to a non-empty board space 
        [[0, 0], [1, 0], [-1, 0], [0, 1], [0, -1]].any? do |dr, dc|
          board.nonempty_space?(row + dr, col + dc)
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
