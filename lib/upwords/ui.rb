module Upwords
  class UI

    def self.loop(game)
      Curses.noecho
      Curses.init_screen
      
      begin
        win = Curses.stdscr
        win.keypad=(true)
        x = 0
        y = 0
        win.setpos(y, x)
        
        # Draw cells
        cell = win.subwin(3, 5, 0, 0)
        (0..3).each do |x|
          (0..3).each do |y|
            win.subwin(3, 5, y * 3, x * 5).box('-', '-')
          end
        end

        win.refresh
        
        # TODO: make this a while-loop
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

    def self.draw_board(game)
      # TODO: Implement...
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

