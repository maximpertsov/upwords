# Encapsulates the shape of a possible move that a player could submit in a single turn
# Component of the Move class

module Upwords
  class Shape

    attr_reader :positions
    
    def initialize(positions = [])
      @positions = Set.new
      positions.reduce(self) {|shape, (row, col)| shape.add(row, col)}
    end

    # Check if move creates a legal shape when added to a given board.
    # NOTE: All checks assume that the move in question has not been played on the board yet.
    def legal?(board, raise_exception = false)        
      if board.empty? && !in_middle_square?(board)
        raise IllegalMove, "You must play at least one letter in the middle 2x2 square!" if raise_exception
      elsif board.empty? && (self.size < board.min_word_length)
        raise IllegalMove, "Valid words must be at least #{board.min_word_length} letter(s) long!" if raise_exception
      elsif !straight_line?
        raise IllegalMove, "The letters in your move must be along a single row or column!" if raise_exception
      elsif !gaps_covered_by?(board)
        raise IllegalMove, "The letters in your move must be internally connected!" if raise_exception
      elsif !(board.empty? || touching?(board))
        raise IllegalMove, "At least one letter in your move must be touching a previously played word!" if raise_exception
      elsif covering_moves?(board)  
        raise IllegalMove, "Cannot completely cover up any previously-played words!" if raise_exception
      else
        return true
      end

      return false
    end

    # Check if move shape completely covers any existing word on the board
    def covering_moves?(board)
      (board.word_positions).any? do |word_posns|
        positions >= word_posns
      end
    end
    
    # Check if all empty spaces in the rows and columns spanned by the move shape are covered by a previously-played tile on board
    # For example, if the move shape = [1,1] [1,2] [1,4], then this method returns 'true' if the board has a tile at position [1,3]
    # and 'false' if it does not.
    def gaps_covered_by?(board)
      row_range.all? do |row|
        col_range.all? do |col|
          @positions.include?([row, col]) || board.nonempty_space?(row, col)
        end
      end
    end
       
    # Check if at least one position within the move shape is adjacent to or overlapping any tile on the board
    def touching?(board)
      @positions.any? do |row, col|
        [[0, 0], [1, 0], [-1, 0], [0, 1], [0, -1]].any? do |dr, dc|
          board.nonempty_space?(row + dr, col + dc)
        end
      end
    end

    # Check if at least one position within the move shape is within the middle 2x2 square on the board
    # This check is only performed at the beginning of the game
    def in_middle_square?(board)
      board.middle_square.any? do |posn|
        @positions.include?(posn)
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
      if row.is_a?(Integer) && col.is_a?(Integer)
        @positions.add [row, col]
        self
      else
        raise ArgumentError, "[#{row}, #{col}] is not a valid position]"
      end
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
