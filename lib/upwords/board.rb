module Upwords
  class Board
    
    # creates a 10 x 10 board
    def initialize(size=10)
      if size.positive?
        @grid = Array.new(size) {Array.new(size) { [] }}
      else
        raise ArgumentError, "Board size must be greater than zero!"
      end
    end
    
    # maximum letters than can be stacked in one space
    def min_word_length
      2
    end

    def max_height
      5
    end

    def in_bounds?(row, col)
      [0 <= row, 
       0 <= col,
       row < num_rows, 
       col < num_columns].all?
    end

    def num_rows
      @grid.size
    end
    
    def num_columns
      @grid[0].size
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
      if !in_bounds?(row, col)
        raise IllegalMove, "#{row}, #{col} is out of bounds!"
      else
        @grid[row][col].size
      end
    end

    def play_letter(letter, row, col)
      if stack_height(row, col) < max_height
        @grid[row][col] << letter
      else
        raise IllegalMove, "You cannot stack any more letters on this space"
      end  
    end

    def remove_top_letter(row, col)
      if !in_bounds?(row, col)
        raise IllegalMove, "#{row}, #{col} is out of bounds!"
      else
        @grid[row][col].pop
      end
    end
  
    # show top letter in board space
    def top_letter(row, col)
      get_letter(row, col, 1)
    end

    def get_letter(row, col, depth=1)
      if !in_bounds?(row, col)
        raise IllegalMove, "#{row}, #{col} is out of bounds!"
      else
        @grid[row][col][-depth] 
      end
    end

    def word_positions
      row_word_posns + column_word_posns
    end

    def nonempty_spaces
      coordinates.select {|row, col| stack_height(row, col) > 0}.to_set
    end

    private

    def collect_word_posns(&block)
      nonempty_spaces.divide(&block).map do |s|
        s.to_a.sort
      end.select {|w| w.length >= min_word_length}
    end

    def row_word_posns
      collect_word_posns {|(r1,c1),(r2,c2)| (c1 - c2).abs == 1 && r1 == r2 }
    end

    def column_word_posns
      collect_word_posns {|(r1,c1),(r2,c2)| (r1 - r2).abs == 1 && c1 == c2 }
    end
    
    def coordinates
      (0...num_rows).to_a.product((0...num_columns).to_a)
      #@grid.each_with_index.map {|letters, row, col| [row, col]}
    end    
  end
end
