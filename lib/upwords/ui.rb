module Upwords
  class UI

    def self.main_loop(game)
      # Initialize Curses
      Curses.noecho
      Curses.curs_set(2)
      Curses.init_screen
      
      begin
        # Initialize window
        win = Curses.stdscr
        win.keypad=(true)
        win.setpos(0, 0)
        
        # Draw board in sub-window
        blines = self.board_lines(10, 10, 4)
        subwin = win.subwin(blines.length, blines[0].length + 1, 0, 0)
        subwin.addstr(blines.join("\n"))
        win.refresh
        
        # Input loop
        while (self.read_key(win, game)) do; end

      ensure
        Curses.close_screen
      end
    end

    def self.board_lines(rows, cols, col_width)
      divider = [nil, ["-" * col_width] * cols, nil].flatten.join("+")
      spaces = [nil, [" " * col_width] * cols, nil].flatten.join("|")
      return ([divider] * (rows + 1)).zip([spaces] * rows).flatten
    end

    def self.read_key(win, game)
      case (key = win.getch)
      when Curses::Key::UP
        win.setpos(win.cury - 1, win.curx)
      when Curses::Key::DOWN
        win.setpos(win.cury + 1, win.curx)
      when Curses::Key::LEFT
        win.setpos(win.cury, win.curx - 1)
      when Curses::Key::RIGHT
        win.setpos(win.cury, win.curx + 1)
      else
        return false
      end

      return key
    end
  end

  class FakeGame
    def initialize
      @board = Array.new(3) {Array.new(3)} # 3 x 3 board
      @players = []
      @x = 0
      @y = 0
    end
  end

end

