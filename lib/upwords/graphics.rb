require 'colored'

module Upwords
  class Graphics

    # Define lines where game info appear
    PLAYER_NAME_LINE = 2
    LETTER_RACK_LINE = 3
    SCORE_LINE = 4

    def initialize(game, init_message = nil)
      @game = game
      @board = @game.board
      @moves = @game.moves
      @message = init_message
    end

    def message=(new_message)
      if new_message.nil?
        @message = ""
      else
        @message = new_message.white
      end
    end

    def format_letter(row, col)
      letter = @board.top_letter(row, col)
      if letter.nil?
        letter = "  "
      # add blank space after all other letters except Qu
      elsif letter != "Qu"
        letter += " "
      end
      # draw pending letters in red
      if @moves.include? [row, col]
        letter.yellow
      else
        letter
      end
    end

    def draw_player_name
      print "   #{@game.current_player.name}'s turn"
    end

    def draw_score
      players = @game.players
      score_display = players.map{|p| "#{p.name}: #{p.score} "}.join "| "
      print "   #{score_display}"
    end
    
    def draw_letter_rack
      print "   #{@game.current_player.show_rack}"
    end

    def draw_space(row, col, cursor_posn)
      # print cursor position in white
      cur_left, cur_right = ["[", "]"].map{|s| s.white}
      if cursor_posn == [row, col]  
        print " #{format_letter(row, col).white_on_blue} |"
      else
        print " #{format_letter(row, col)} |"
      end
    end

    # This will also display the stack height for now
    def draw_divider(row, col)
      height = @board.stack_height(row, col)
      case height
      when 0
        height = "-"
      when @board.max_height
        height = height.to_s.red
      else
        height = height.to_s.white
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
        elsif i == SCORE_LINE
          draw_score
        end
        print "\n+"
        row.each_index{|j| draw_divider(i, j)}
      end
      print "\n#{@message}\n" 
    end

  end
end
