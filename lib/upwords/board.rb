module Upwords
  class Board
    
    # creates a 10 x 10 board
    def initialize(size=10)
      @grid = Matrix.build(size) { [] }
    end
    
    # maximum letters than can be stacked in one space
    def min_word_length
      2
    end

    def max_height
      5
    end
    
    def num_rows
      @grid.row_size
    end
    
    def num_columns
      @grid.column_size
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
      @grid[row, col].size
    end

    def play_letter(letter, row, col)
      if stack_height(row, col) < max_height
        @grid[row, col] << letter
      else
        raise IllegalMove, "You cannot stack any more letters on this space"
      end  
    end

    def remove_top_letter(row, col)
      @grid[row, col].pop
    end
  
    # show top letter in board space
    def top_letter(row, col)
      @grid[row, col][-1]
    end

    def words
      row_words + column_words
    end

    def nonempty_spaces
      coordinates.select {|row, col| stack_height(row, col) > 0}.to_set
    end

    private

    def collect_words(&block)
      nonempty_spaces.divide(&block).map do |s|
        Word.new(self, s.to_a.sort)
      end.select {|w| w.length >= min_word_length}
    end

    def row_words
      collect_words {|(r1,c1),(r2,c2)| (c1 - c2).abs == 1 && r1 == r2 }
    end

    def column_words
      collect_words {|(r1,c1),(r2,c2)| (r1 - r2).abs == 1 && c1 == c2 }
    end
    
    def coordinates
      @grid.each_with_index.map {|letters, row, col| [row, col]}
    end    
  end
end
