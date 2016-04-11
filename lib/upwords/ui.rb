module Upwords
  class UI

    def initialize(game)
      @game = game

      # Configure Curses and initialize screen
      Curses.noecho
      Curses.curs_set(2)
      Curses.init_screen
   
      begin
        @win = Curses.stdscr
        @win.keypad=(true)
        @win.setpos(0, 0) # TODO: Change this to top-left of middle square
        main_loop
      ensure
        Curses.close_screen
      end
    end

    def main_loop
      # Draw board in sub-window
      self.draw

      # Input loop
      while (self.read_key) do; end
    end

    def draw
      blines = self.board_lines(@game.board, 4) 
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
      
      # Update Curses cursor to new game cursor
      @win.setpos((@game.cursor.y * 2) + 1, (@game.cursor.x * 5) + 2)
      return key
    end

    private

    def win_pos(y, x)
      [(y * 2) + 1, (x * 5) + 2]
    end
  end

  class FakeGame < Game
    def initialize
      super(false, 1)
    end
  end

end

