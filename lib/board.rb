module Upwords
  # 10 x 10 board
  class Board 

    attr_reader :grid, :letter_bank

    def initialize
      @grid = Array.new(num_rows) {Array.new(num_columns) {Array.new}}
      @letter_bank = LetterBank.new
    end
    
    def num_rows
      10
    end
    
    def num_columns
      10
    end

    # Defines a 4x4 square in the middle of the board (in the case of the 10 x 10 board)
    # The top left corner of the square is the initial cursor position
    # The square itself defines the region where at least one of the first letters must be placed
    def middle_square
      mid_square = []
      row0, row1 = num_rows / 3, num_rows - num_rows / 3
      col0, col1 = num_columns / 3, num_columns - num_columns / 3
      (row0...row1).each do |i|
        (col0...col1).each{ |j| mid_square << [i,j] }
      end
      mid_square
    end

    # maximum letters than can be stacked in one space
    def max_height
      5
    end

    def stack_height(row, col)
      @grid[row][col].size
    end

    def play_letter(letter, row, col)
      if stack_height(row, col) < max_height 
        @grid[row][col] << letter
      else
        raise IllegalMove, "You cannot stack any more letters on this space"
      end  
    end

    def remove_top_letter(row, col)
      @grid[row][col].pop
    end

    # show top letter in board space
    def top_letter(row, col)
      @grid[row][col][-1]
    end

  end
end
