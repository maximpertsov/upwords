module Upwords
  class UI

    def self.loop(game)
      Curses.init_screen
      
      begin
        win = Curses.stdscr
        win.keypad=(true)
        x = 0
        y = 0
        win.setpos(y, x)
        win.addstr("Hello World")
        win.refresh
        self.read_key(win, game)
        win.getch
      ensure
        Curses.close_screen
      end
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

    def up
      @y = (@y - 1) % @board.size
    end
  end

end

