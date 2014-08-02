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
