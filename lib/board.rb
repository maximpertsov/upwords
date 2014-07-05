module Upwords
  # 10 x 10 board
  class Board 

    attr_reader :letter_bank

    def initialize
      @grid = Array.new(num_rows) {Array.new(num_columns) { Array.new(max_height)}}
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

    def update_cursor_location(row, col)
      @cursor_location = [(@cursor_location[0] + row) % num_rows, 
                          (@cursor_location[1] + col) % num_columns]
    end

    # get number of letters stacked in a board space
    def stack_height(row, col)
      @grid[row][col].compact.size
    end

    # place letter on board space
    ## UPDATE to take position from @cursor_location instead of taking
    ## row and col parameters
    def play_letter(letter)
      row, col = @cursor_location[0], @cursor_location[1]
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

    # ------------------------
    # PRINT TO CONSOLE METHODS
    # ------------------------
    # ideally, this app will eventually have a proper gui, 
    # and these methods will no longer be necessary

    def letter_to_console(row, col)
      cursor = " "
      if row == @cursor_location[0] && col == @cursor_location[1]
        cursor = "*"
      end
      print_letter = top_letter(row, col)
      if print_letter.nil?
        print_letter = "  "
      elsif print_letter != "Qu"
        print_letter += " "
      end
      print " #{print_letter}#{cursor}|"
    end
    
    def stack_height_to_console(row, col)
      print_height = stack_height(row, col)
      if print_height == 0
        print_height = "-"
      end
      print "---#{print_height}+"
    end

    # print grid of top letter on each stack and stack height
    def show_in_console
      print "\n\n\n+" + "----+" * num_columns
      @grid.each_with_index do |row, i| 
        print "\n|"
        row.each_index{|j| letter_to_console(i, j)}
        print "\n+"
        row.each_index{|j| stack_height_to_console(i, j)}
      end
      print "\n"
    end
    
  end
end
