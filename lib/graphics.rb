module Upwords
  class Graphics

    def initialize(board)
      @board = board
    end

    def format_letter(row, col)
      letter = @board.top_letter(row, col)
      if letter.nil?
        letter = "  "
      # add blank space after all other letters except Qu
      elsif letter != "Qu"
        letter += " "
      end
      letter
    end

    def draw_space(row, col)
      cursor_loc = @board.cursor_location
      if [row, col] == [cursor_loc[0], cursor_loc[1]]
        print "[#{format_letter(row, col)}]|"
      else
        print " #{format_letter(row, col)} |"
      end
    end

    # This will also display the stack height for now
    def draw_divider(row, col)
      height = @board.stack_height(row, col)
      if height == 0
        height = "-"
      end
      print "---#{height}+"
    end

    # print grid of top letter on each stack and stack height
    def draw_board
      print "\n\n\n+" + "----+" * @board.num_columns
      @board.letter_grid.each_with_index do |row, i| 
        print "\n|"
        row.each_index{|j| draw_space(i, j)}
        print "\n+"
        row.each_index{|j| draw_divider(i, j)}
      end
      print "\n"
    end
    
  end
end
