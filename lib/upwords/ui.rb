module Upwords
  class UI

    def initialize(game, row_height = 1, col_width = 4)
      # Game and drawing variables
      @game = game
      @rows = game.board.num_rows
      @cols = game.board.num_columns
      @row_height = row_height
      @col_width = col_width
      @rack_visible = false

      # Configure Curses and initialize screen
      Curses.noecho
      Curses.curs_set(2)
      Curses.init_screen
      Curses.start_color

      # Initialize colors
      Curses.init_pair(RED, Curses::COLOR_RED, Curses::COLOR_BLACK) # Red on black background
      Curses.init_pair(YELLOW, Curses::COLOR_YELLOW, Curses::COLOR_BLACK) # Yellow on black background

      # Initialize main window and game loop
      begin
        @win = Curses.stdscr
        @win.keypad=(true)
        @win.setpos(*letter_pos(*@game.cursor.posn))
        draw_update_loop
      ensure
        Curses.close_screen
      end      
    end

    def draw_update_loop
      draw_grid
      draw_player_info
  
      # Read key inputs then update cursor and window
      while read_key do
        @win.setpos(*letter_pos(*@game.cursor.posn))
        draw_letters
        draw_stack_heights
        draw_player_info # TODO: remove duplicate method?
      end
    end

    def draw_message(text)
      draw_wrapper do
        @win.setpos(*message_pos)
        @win.addstr(text)
      end
    end

    def draw_player_info
      draw_wrapper do
        @game.players.each_with_index do |p, i|
          # Delete old player information
          @win.setpos(*player_info_pos(i))
          @win.addstr(" " * (@win.maxx - @win.curx - 1))  
          # Draw new player information
          @win.setpos(*player_info_pos(i))
          @win.addstr(sprintf("%s %-8s %4d   %s", 
                              p == @game.current_player ? "->" : "  ", 
                              "#{p.name}:", 
                              p.score,
                              p == @game.current_player ? "#{p.show_rack(masked=!@rack_visible)}" : ""))
        end
      end
    end

    def clear_message
      draw_wrapper do
        @win.setpos(*message_pos)
        (@win.maxy - @win.cury + 1).times { @win.deleteln } # Delete ALL lines below cursor
      end
    end

    def draw_confirm(text) 
      draw_message(text)
      reply = (@win.getch.to_s).upcase == "Y"
      clear_message

      return reply
    end

    def draw_grid
      draw_wrapper do
        # create a list containing each line of the board string
        divider = [nil, ["-" * @col_width] * @cols, nil].flatten.join("+")
        spaces = [nil, [" " * @col_width] * @cols, nil].flatten.join("|")
        lines = ([divider] * (@rows + 1)).zip([spaces] * @rows).flatten

        # concatenate board lines and draw in a sub-window on the terminal
        @win.setpos(0, 0)
        @win.addstr(lines.join("\n"))
      end
    end

    def draw_letters
      board = @game.board

      draw_for_each_cell do |row, col|
        @win.setpos(*letter_pos(row, col))
        
        if board.nonempty_space?(row, col)
          letter = board.top_letter(row, col)
          if @game.pending_position?(row, col)
            Curses.attron(Curses.color_pair(YELLOW)) { @win.addstr(letter) }  
          else
            @win.addstr(letter)      
          end  
        else
          @win.addstr("  ")
        end
      end
    end

    def draw_stack_heights
      board = @game.board

      draw_for_each_cell do |row, col|        
        @win.setpos(*stack_height_pos(row, col))

        case (height = board.stack_height(row, col))
        when 0
          @win.addstr("-")
        when board.max_height
          Curses.attron(Curses.color_pair(RED)) { @win.addstr(height.to_s) }
        else
          @win.addstr(height.to_s)
        end
      end
    end

    # TODO: if read_key returns 'false', then the game ends. See if there is a better construct...
    def read_key
      case (key = @win.getch)
      when DELETE
        @game.undo_last
      when Curses::Key::UP
        @game.cursor.up
      when Curses::Key::DOWN
        @game.cursor.down
      when Curses::Key::LEFT
        @game.cursor.left
      when Curses::Key::RIGHT
        @game.cursor.right
      when SPACE
        @rack_visible = !@rack_visible
      when ENTER
        if draw_confirm("Are you sure you wanted to submit? (y/n)")  
          @game.submit_moves 
          @game.next_turn
          @rack_visible = false
        end
      when /[[:alpha:]]/
        @game.play_letter(key)
      else
        return false # TODO: should input be controlling the game loop?
      end
      
      return key

    rescue IllegalMove => exception
      draw_confirm("#{exception.message} (press any key to continue...)")
      return true 
    end

    private
  
    def letter_pos(row, col)
      [(row * (@row_height + 1)) + 1, (col * (@col_width + 1)) + 2] # TODO: magic nums are offsets 
    end

    def stack_height_pos(row, col)
      [(row * (@row_height + 1)) + 2, (col * (@col_width + 1)) + @col_width] # TODO: magic nums are offsets
    end

    def message_pos
      [@rows * (@row_height + 1) + 2, 0] # TODO: magic nums are offsets
    end

    def player_info_pos(player_number = 0)
      [1 + player_number, @cols * (@col_width + 1) + 4] # TODO: magic_nums are offsets
    end

    # Execute draw operation in block and reset cursors and refresh afterwards
    def draw_wrapper(&block)
      cury, curx = @win.cury, @win.curx
      
      yield block if block_given? 
      
      @win.setpos(cury, curx)
      @win.refresh
    end

    def draw_for_each_cell(&block)
      draw_wrapper do
        (0...@rows).each do |row|
          (0...@cols).each { |col| block.call(row, col)}
        end
      end
    end
  end

  class FakeGame < Game
    def initialize
      super(display_on=false, 2)
      self.add_player("Max")
      self.add_player("Jordan")

      self.all_refill_racks
    end
  end

end

