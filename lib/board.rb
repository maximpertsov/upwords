module Upwords
  # 10 x 10 board
  class Board 

    attr_reader :letter_bank

    def initialize
      @grid = Array.new(num_rows) {Array.new(num_columns) { Array.new(max_height)}}
      @letter_bank = LetterBank.new
      @selected_space = [0, 0]
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

    def selected_space=(row, col)
      @selected_space = [row % num_rows, col % num_columns]
    end

    # get number of letters stacked in a board space
    def stack_height(row, col)
      @grid[row][col].compact.size
    end

    # place letter on board space
    ## UPDATE to take position from @selected_space instead of taking
    ## row and col parameters
    def play_letter(letter, row, col)
      height = stack_height(row, col)
      if height >= max_height 
        raise IllegalMove, "You cannot stack any more letters on this space"
      else
        @grid[row][col][height] = letter
      end  
    end

    # get top letter in board space
    def top_letter(row, col)
      current_height = stack_height(row, col)
      if current_height == 0
        nil
      else
        @grid[row][col][current_height - 1]
      end
    end

    def show_space(row, col)
      cursor = " "
      if row == @selected_space[0] && col == @selected_space[1]
        cursor = "*"
      end
      print "[#{top_letter(row, col)}, #{stack_height(row, col)}#{cursor}] "
    end

    # print grid of top letter on each stack and stack height
    def show
      @grid.each_with_index do |row, i| 
        print "\n"
        row.each_index{|j| show_space(i, j)}
      end
      print "\n"
    end
  
  end
end
