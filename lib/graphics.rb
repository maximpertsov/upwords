module Upwords
  class Graphics

    def initialize(game, board, message = nil)
      @game = game
      @board = board
      @message = message
    end

    def message=(new_message)
      @message = new_message
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

    def draw_player_name
      print "   #{@game.current_player.name}'s turn"
    end

    def draw_letter_rack
      print "   #{@game.current_player.show_rack}"
    end

    def draw_space(row, col, cursor_posn)
      if cursor_posn == [row, col]  
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
      @board.grid.each_with_index do |row, i| 
        print "\n|"
        row.each_index{|j| draw_space(i, j, @game.current_player.cursor_posn)}
        if i == PLAYER_NAME_LINE
          draw_player_name
        elsif i == LETTER_RACK_LINE
          draw_letter_rack
        end
        print "\n+"
        row.each_index{|j| draw_divider(i, j)}
      end
      print "\n"
      print @message
    end

    # Define lines where game info appear
    PLAYER_NAME_LINE = 2
    LETTER_RACK_LINE = 3
    
  end
end
