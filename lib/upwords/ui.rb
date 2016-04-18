module Upwords
  class UI

    def initialize(game, row_height = 1, col_width = 4)
      # Game and drawing variables
      @game = game
      @row_height = row_height
      @col_width = col_width

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

      # Read key inputs then update cursor and window
      while read_key do
        @win.setpos(*letter_pos(*@game.cursor.posn))
        draw_letters(@game.board)
        draw_stack_heights(@game.board)
      end
    end

    def draw_message(text)
      draw_wrapper do
        @win.setpos(*message_pos(@game.board))
        @win.addstr(text)
      end
    end

    def clear_message
      draw_wrapper do
        y, x = message_pos(@game.board)
        @win.setpos(y, x)
        # Delete ALL lines below cursor
        (@win.maxy - y + 1).times { @win.deleteln }
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
        lines = board_lines(@game.board, @col_width) 
        subwin = @win.subwin(lines.length, lines[0].length + 1, 0, 0)
        subwin.addstr(lines.join("\n"))
      end
    end

    def board_lines(board, col_width) 
      rows = board.num_rows
      cols = board.num_columns

      divider = [nil, ["-" * col_width] * cols, nil].flatten.join("+")
      spaces = [nil, [" " * col_width] * cols, nil].flatten.join("|")

      return ([divider] * (rows + 1)).zip([spaces] * rows).flatten
    end

    def draw_letters(board)
      draw_for_each_cell(board) do |row, col|
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

    def draw_stack_heights(board)
      draw_for_each_cell(board) do |row, col|
        
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
        # TODO: remove the confirmation script - it was only meant to be a test
        if draw_confirm("Are you sure you want to undo? (y/n)")
          @game.undo_last
        end
      when Curses::Key::UP
        @game.cursor.up
      when Curses::Key::DOWN
        @game.cursor.down
      when Curses::Key::LEFT
        @game.cursor.left
      when Curses::Key::RIGHT
        @game.cursor.right
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

    def message_pos(board)
      [board.num_rows * (@row_height + 1) + 2, 0] # TODO: magic nums are offsets
    end

    # Execute draw operation in block and reset cursors and refresh afterwards
    def draw_wrapper(&block)
      cury, curx = @win.cury, @win.curx
      
      yield block if block_given? 
      
      @win.setpos(cury, curx)
      @win.refresh
    end

    def draw_for_each_cell(board, &block)
      draw_wrapper do
        (0...board.num_rows).each do |row|
          (0...board.num_columns).each do |col|
            block.call(row, col)
          end
        end
      end
    end
  end

  class FakeGame < Game
    def initialize
      super(false, 2)
      self.add_player("Max")
      self.add_player("Jordan")

      # Give each each player letters A through G 
      self.players.each do |p|
        ('A'..'G').each do |letter|
          p.take_letter(letter)
        end
      end
    end
  end

end

