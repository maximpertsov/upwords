module Upwords
  class Board
    
    attr_accessor :max_height, :size

    # creates a 10 x 10 board
    def initialize(size=10, max_height=5)
      if !size.positive?
        raise ArgumentError, "Board size must be greater than zero!"
      else
        @size = size
        @max_height = max_height
        @grid = Hash.new do |h, (row, col)|
          if row < 0 || col < 0 || num_rows <= row || num_columns <= col
            raise IllegalMove, "#{row}, #{col} is out of bounds!"
          else
            h[[row, col]] = []    # Initialize with empty array
          end
        end
      end
    end
    
    def empty?
      @grid.empty? || @grid.each_key.all? {|k| @grid[k].empty?}
    end

    def nonempty_space?(row, col)
      @grid.key?([row, col]) && stack_height(row, col) > 0
    end

    # maximum letters than can be stacked in one space
    def min_word_length
      2
    end

    def num_rows
      @size
    end
    
    def num_columns
      @size
    end

    # Defines a 2x2 square in the middle of the board (in the case of the 10 x 10 board)
    # The top left corner of the square is the initial cursor position
    # The square itself defines the region where at least one of the first letters must be placed
    def middle_square
      [1, 0].product([1, 0]).map do |r, c|
        [(num_rows) / 2 - r, (num_columns) / 2 - c]
      end
    end

    def stack_height(row, col)
      @grid[[row, col]].size
    end

    def play_move(move)
      move.play(self)
    end

    def undo_move(move)
      move.remove_from(self)
    end

    def can_play_letter?(letter, row, col, raise_exception = false)
      if stack_height(row, col) == max_height
        raise IllegalMove, "You cannot stack any more letters on this space" if raise_exception
      elsif top_letter(row, col) == letter
        raise IllegalMove, "You cannot stack a letter on the same letter!" if raise_exception
      else 
        return true
      end
      return false
    end

    def play_letter(letter, row, col)
      if can_play_letter?(letter, row, col, raise_exception = true)
        @grid[[row, col]] << letter
        return [[row, col], letter] # Return position after successfully playing a move
      end  
    end

    def remove_top_letter(row, col)
      @grid[[row, col]].pop
    end
    
    # show top letter in board space
    def top_letter(row, col)
      get_letter(row, col, 1)
    end

    def get_letter(row, col, depth=1)
      @grid[[row, col]][-depth]
    end

    def word_positions
      row_word_posns + column_word_posns
    end

    def nonempty_spaces
      coordinates.select {|row, col| nonempty_space?(row, col)}.to_set
    end

    def coordinates
      (0...num_rows).to_a.product((0...num_columns).to_a)
    end    

    private

    def collect_word_posns(&block)
      SortedSet.new(nonempty_spaces).divide(&block).select do |w| 
        w.length >= min_word_length
      end.to_set
    end

    def row_word_posns
      collect_word_posns {|(r1,c1),(r2,c2)| (c1 - c2).abs == 1 && r1 == r2 }
    end

    def column_word_posns
      collect_word_posns {|(r1,c1),(r2,c2)| (r1 - r2).abs == 1 && c1 == c2 }
    end
    
  end
end
