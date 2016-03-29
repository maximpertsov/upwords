# require 'colored'

module Upwords
  class Graphics < Curses::Window
    
    def initialize(game)
      super(0,0,0,0)
      @game = game
      @board = @game.board
      @cursor = @game.cursor 
      @message = ''
      @rack_visibility = false
    end
    
    def refresh
      clear
      self << self.to_s
      super
    end
    
    def to_s
      (draw_board + draw_message).zip(draw_stats).map do |board_row, stats_row|
        (board_row.to_s) + (stats_row.to_s)
      end.join("\n")
    end

    def message=(new_message)
      if new_message.nil?
        @message = ""
      else
        @message = new_message 
      end
    end

    def show_rack
      @rack_visibility = true
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
    end

    def draw_player_name
      "#{@game.current_player.name}'s turn"
    end

    def draw_score(player)
      "#{player.name}'s Score: #{player.score}" 
    end

    def draw_last_turn(player)
      "Last Move: #{player.last_turn}"
    end

    def draw_letter_rack
      "Letters: #{@game.current_player.show_rack(!@rack_visibility)} "
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
      b = [draw_row_divider(0, false)]
      
      (0...@board.num_rows).each do |i|
        b << draw_row(i, @cursor.posn)
        b << draw_row_divider(i)
      end

      b.to_a
    end
    
    def draw_message
      ["", "", @message.to_s]
    end

    def draw_stats
      ["--------------------",
       draw_score(@game.players[0]),
       "",
       draw_letter_rack,
       "--------------------",
       "",
       @game.player_count > 1 ?draw_score(@game.players[1]) : "",
       "",         
       @game.player_count > 2 ? draw_score(@game.players[2]) : "",
       "",
       @game.player_count > 3 ? draw_score(@game.players[3]) : "",
       "",
       "---------------------",
       "|      Controls     |",
       "---------------------",
       "Show Letters  [SPACE]",
       "Undo Moves    [DEL]",
       "Submit Move   [ENTER]",
       "Swap Letter   [+]",
       "Skip Turn     [-]",
       "Quit Game     [SHIFT+Q]"].map{|s| "   #{s}"} # Left padding
    end

  end
end
