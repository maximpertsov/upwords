# require 'colored'

module Upwords
  class Graphics
    
    # Define lines where game info appear
    PLAYER_NAME_LINE = 1
    LETTER_RACK_LINE = 2
    SCORE_LINE = 3

    def initialize(game, cursor, init_message = nil)
      @game = game
      @board = @game.board
      @cursor = cursor 
      @message = init_message
      @rack_visibility = false
    end

    def to_s
      draw_board
    end

    def message=(new_message)
      if new_message.nil?
        @message = ""
      else
        @message = new_message #.white
      end
    end

    def show_rack #toggle_rack_visibility
      @rack_visibility = true #!@rack_visibility
    end

    def hide_rack
      @rack_visibility = false
    end

    def toggle_rack_visibility
      @rack_visibility = !@rack_visibility
    end

    private
    
    def format_letter(row, col)
      letter = @board.top_letter(row, col)
      if letter.nil?
        letter = "  "
      # add blank space after all other letters except Qu
      elsif letter != "Qu"
        letter += " "
      end
      letter
      # # draw pending letters in red
      # if @moves.include? [row, col]
      #   letter #.yellow
      # else
      #   letter
      # end
    end

    def draw_player_name
      "   #{@game.current_player.name}'s turn"
    end

    def draw_score
      players = @game.players
      score_display = players.map{|p| "#{p.name}: #{p.score} "}.join "| "
      "   #{score_display}"
    end
    
    def draw_letter_rack
      "   #{@rack_visibility ? @game.current_player.show_rack : @game.current_player.show_hidden_rack} "
    end

    def draw_space(row, col, cursor_posn)
      cursor = cursor_posn == [row, col] ? "*" : " "
      "#{cursor}#{format_letter(row, col)} "
    end

    def draw_row(row, cursor_posn)
      ["|",
       (0...@board.num_columns).map do |col|
         draw_space(row, col, cursor_posn)
       end.join("|"),
       "|"].join
    end

    # This will also display the stack height for now
    def draw_divider(row, col, show_height=true)
      height = @board.stack_height(row, col)
      if show_height && height > 0
        height = height.to_s
      else
        height = "-"
      end
      "---#{height}"
    end

    def draw_row_divider(row, show_height=true)
      ["+",
       (0...@board.num_columns).map do |col|
         draw_divider(row, col, show_height)
       end.join("+"),
       "+"].join
    end
    
    # print grid of top letter on each stack and stack height
    def draw_board
      [draw_row_divider(0, false),
       "\n",
       (0...@board.num_rows).map do |i|
         [draw_row(i, @cursor.posn), #@game.current_player.cursor_posn),
          if i == PLAYER_NAME_LINE
            draw_player_name
          elsif i == LETTER_RACK_LINE
            draw_letter_rack
          elsif i == SCORE_LINE
            draw_score
          else
            ""
          end,
          "\n",
          draw_row_divider(i),
          "\n"].join
       end.join,
       "\n#{@message}\n"].join
    end

  end
end
