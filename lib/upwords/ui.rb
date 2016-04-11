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

      # Initialize main window and game loop
      begin
        @win = Curses.stdscr
        @win.keypad=(true)
        @win.setpos(*win_pos(*@game.cursor.posn))
        draw_update_loop
      ensure
        Curses.close_screen
      end      
    end

    def draw_update_loop
      draw

      # Read key inputs then update cursor and window
      while read_key do
        @win.setpos(*win_pos(*@game.cursor.posn))
        @win.refresh
      end
    end

    def draw
      # Draw board in sub-window
      blines = self.board_lines(@game.board, @col_width) 
      subwin = @win.subwin(blines.length, blines[0].length + 1, 0, 0)
      subwin.addstr(blines.join("\n"))
      @win.refresh
    end

    def board_lines(board, col_width) 
      rows = board.num_rows
      cols = board.num_columns

      divider = [nil, ["-" * col_width] * cols, nil].flatten.join("+")
      spaces = [nil, [" " * col_width] * cols, nil].flatten.join("|")

      return ([divider] * (rows + 1)).zip([spaces] * rows).flatten
    end

    def read_key
      case (key = @win.getch)
      when Curses::Key::UP
        @game.cursor.up
      when Curses::Key::DOWN
        @game.cursor.down
      when Curses::Key::LEFT
        @game.cursor.left
      when Curses::Key::RIGHT
        @game.cursor.right
      else
        return false
      end
      
      return key
    end

    private

    def win_pos(y, x)
      dy = @row_height
      dx = @col_width
      [(y * (dy + 1)) + 1, (x * (dx + 1)) + 2] # TODO: magic nums are offsets 
    end
  end

  class FakeGame < Game
    def initialize
      super(false, 1)
    end
  end

end

