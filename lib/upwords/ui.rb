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
      Curses.curs_set(2)  # Blinking cursor
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

    # ==================================
    # Main methods: draw and input loops
    # ==================================

    def draw_update_loop
      draw_grid
      draw_controls

      # TODO: make this the main game loop
      while true do
        draw_player_info
        draw_message "#{@game.current_player.name}'s turn"

        # TODO: make CPU move subroutine it's own method
        if @game.current_player.cpu?
          draw_message "#{@game.current_player.name} is thinking..."
          cpu_move = @game.current_player.cpu_move(@game.board, @game.dict, sample_size=50, min_score=10)
            
          if !cpu_move.nil?
            cpu_move.each { |pos, letter| @game.play_letter(letter, *pos) }
            @game.submit_moves
          else
            @game.skip_turn
          end
        else
          # TODO: make human player subroutine it's own method
          # Read key inputs then update cursor and window
          while read_key do
            @win.setpos(*letter_pos(*@game.cursor.posn))
            draw_letters
            draw_stack_heights
            draw_player_info # TODO: remove duplicate method?
          end
        end

        draw_letters  # Draw letters again to remove any highlights          
        draw_stack_heights

        @game.next_turn
        @rack_visible = false
      end
    end

   # TODO: See if there is a better construct...
    # TODO: if read_key returns 'false', then current iteration of the input loop ends
    def read_key
      case (key = @win.getch)      
      when 'Q'
        @game.exit_game if draw_confirm("Are you sure you want to exit the game? (y/n)")
      when DELETE
        @game.undo_last
        draw_message(@game.standard_message) # TODO: factor this method
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
          @game.submit_moves # TODO: update this method
          return false
        end
      when '+'
        draw_message("Pick a letter to swap")
        letter = @win.getch
        if letter =~ /[[:alpha:]]/ && draw_confirm("Swap '#{letter}' for a new letter? (y/n)")
          @game.swap_letter(letter)
          return false
        else
          draw_message("'#{letter}' is not a valid letter")
        end
      when '-'
        if draw_confirm("Are you sure you wanted to skip your turn? (y/n)")  
          @game.skip_turn # TODO: update this method
          return false
        end
      when /[[:alpha:]]/
        @game.play_letter(key)
        draw_message(@game.standard_message) # TODO: factor this method
      end
      
      return true

    rescue IllegalMove => exception
      draw_confirm("#{exception.message} (press any key to continue...)")
      return true 
    end

    # =============================
    # Draw individual game elements
    # =============================

    def draw_message(text)
      write_str(*message_pos, text, clear_below=true)
    end

    def clear_message
      draw_message("")
    end

    def draw_player_info
      draw_wrapper do
        py, px = player_info_pos
        
        # Draw rack for current player only          
        write_str(py, px, "#{@game.current_player.name}'s letters:", clear_right=true)
        write_str(py+1, px, "[#{@game.current_player.show_rack(masked=!@rack_visible)}]", clear_right=true)

        @game.players.each_with_index do |p, i|
          write_str(py+i+3, px, sprintf("%s %-8s %4d", p == @game.current_player ? "->" : "  ", "#{p.name}:", p.score), clear_right=true)
        end
      end
    end

    # TODO: make confirmation options more clear
    def draw_confirm(text) 
      draw_message("#{text}")
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

    def draw_controls
      draw_wrapper do
        y, x = controls_info_pos
        ["----------------------",
         "|      Controls      |",
         "----------------------",
         "Show Letters   [SPACE]",
         "Undo Last Move [DEL]",
         "Submit Move    [ENTER]",
         "Swap Letter    [+]",
         "Skip Turn      [-]",
         "Quit Game      [SHIFT+Q]"].each_with_index do |line, i|
          @win.setpos(y+i, x)
          @win.addstr(line)
        end
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

    private
  
    # ======================================
    # Get positions of various game elements
    # ======================================

    def letter_pos(row, col)
      [(row * (@row_height + 1)) + 1, (col * (@col_width + 1)) + 2] # TODO: magic nums are offsets 
    end

    def stack_height_pos(row, col)
      [(row * (@row_height + 1)) + 2, (col * (@col_width + 1)) + @col_width] # TODO: magic nums are offsets
    end

    def message_pos
      [@rows * (@row_height + 1) + 2, 0] # TODO: magic nums are offsets
    end

    def player_info_pos
      [1, @cols * (@col_width + 1) + 4] # TODO: magic_nums are offsets
    end

    def controls_info_pos
      y, x = player_info_pos
      return [y + (@rows * (@row_height + 1)) / 2 + 1, x] # TODO: magic_nums are offsets
    end

    # ======================
    # Drawing helper methods
    # ======================

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

    # Write text to position (y, x) of the terminal
    # Optionally, delete all text to the right or all lines below before writing text
    def write_str(y, x, text, clear_right = false, clear_below = false)
      draw_wrapper do
        @win.setpos(y, x)
        draw_wrapper { @win.addstr(" " * (@win.maxx - @win.curx)) } if clear_right
        draw_wrapper { (@win.maxy - @win.cury + 1).times { @win.deleteln } } if clear_below
        draw_wrapper { @win.addstr(text) }
      end
    end
  end

end

