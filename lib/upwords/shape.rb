module Upwords
  class Shape

    attr_reader :positions
    
    def initialize(positions = [])
      @positions = Set.new
      positions.reduce(self) {|shape, (row, col)| shape.add(row, col)}
    end

    # Check if a move has a legal shape on a given board. Note that all 
    # checks assume that the move in question has not been played yet.
    def legal?(board, raise_exception = false)        
      if (board.empty? && !in_middle_square?(board))
        if raise_exception
          raise IllegalMove, "You must play at least one letter in the middle 2x2 square!"
        end
      elsif (board.empty? && (@positions.size < board.min_word_length))
        if raise_exception
          raise IllegalMove, "Valid words must be at least #{board.min_word_length} letter(s) long!"
        end
      elsif !straight_line?
        if raise_exception
          raise IllegalMove, "The letters in your move must be along a single row or column!"
        end
      elsif !gaps_covered_by?(board)
        if raise_exception
          raise IllegalMove, "The letters in your move must be internally connected!"
        end
      elsif !(board.empty? || touching?(board))
        if raise_exception
          raise IllegalMove, "At least one letter in your move must be touching a previously played word!"
        end
      elsif covering_moves?(board)  
        if raise_exception
          raise IllegalMove, "Cannot completely cover up any previously-played words!"
        end
      else
        return true
      end

      return false
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
