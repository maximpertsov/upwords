module Upwords
  # 10 x 10 board
  class Board 

    attr_reader :grid, :letter_bank, :cursor_location

    def initialize
      @grid = Array.new(num_rows) {Array.new(num_columns) {Array.new}}
      @letter_bank = LetterBank.new
      @cursor_location = [0, 0]
    end

    def num_columns
      10
    end

    def num_rows
      10
    end

    # maximum letters than can be stacked in one space
    def max_height
      5
    end

    def move_cursor(row, col)
      @cursor_location = [(@cursor_location[0] + row) % num_rows, 
                          (@cursor_location[1] + col) % num_columns]
    end

    # get number of letters stacked in a board space
    def stack_height(row, col)
      @grid[row][col].size
    end

    # place letter on board space
    ## UPDATE to take position from @cursor_location instead of taking
    ## row and col parameters
    def play_letter(letter)
      row, col = @cursor_location[0], @cursor_location[1]
      if stack_height(row, col) < max_height 
        @grid[row][col] << letter
      else
        raise IllegalMove, "You cannot stack any more letters on this space"
      end  
    end

    # show top letter in board space
    def top_letter(row, col)
      @grid[row][col][-1]
    end

  end
end
