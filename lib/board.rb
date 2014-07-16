module Upwords
  # 10 x 10 board
  class Board 

    attr_reader :letter_grid, :submit_grid, :letter_bank, :cursor_location

    def initialize
      @letter_grid = Array.new(num_rows) {Array.new(num_columns) {Array.new}}
      @submit_grid = Array.new(num_rows) {Array.new(num_columns) {true}}
      @pending_moves = Array.new # keeps track of unsubmitted grid spaces
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
      @cursor_location = [(@cursor_location[0] + row) % num_rows, (@cursor_location[1] + col) % num_columns]
    end

    def stack_height(row, col)
      @letter_grid[row][col].size
    end

    # place a letter on the board. This play will initially be unsubmitted
    def play_letter(letter)
      row, col = @cursor_location[0], @cursor_location[1]
      if stack_height(row, col) < max_height and !@submit_grid[row][col]
        @letter_grid[row][col] << letter
        # TODO: move the next two lines to a separate submission tracker class?
        @submit_grid[row][col] = false
        @pending_moves << [row, col]
      else
        raise IllegalMove, "You cannot stack any more letters on this space"
      end  
    end

    def submit_moves
      while @pending_moves.size > 0 do
        move = @pending_moves.pop
        @submit_grid[move[0]][move[1]] = true
      end
    end

    def remove_top_letter(letter)
      row, col = @cursor_location[0], @cursor_location[1]
      @letter_grid[row][col].pop
    end

    # show top letter in board space
    def top_letter(row, col)
      @letter_grid[row][col][-1]
    end

  end
end
