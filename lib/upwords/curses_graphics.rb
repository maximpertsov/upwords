require 'curses'

module Upwords
  class CursesGraphics
    
    def initialize(game, init_message = nil)
      @game = game
      @board = @game.board
      @moves = @game.moves
      @message = init_message
    end

    # =========================================
    # Curses
    # =========================================

    def open_window
      Curses.init_screen
      Curses.start_color
      @win = Curses::Window.new(0,0,0,0)
    end

    def close_window
      @win.close
    end

    def draw_grid(dim)
      sz_x, sz_y = SPACE_SIZE_X, SPACE_SIZE_Y
      (0...dim).each do |j|
        (0...dim).each {|i| draw_cell(sz_x, sz_y, i*(sz_x-1), j*(sz_y-1))}
      end
      @win.setpos(CURSOR_START_Y, CURSOR_START_X)
    end

    # TODO: make this a private method ?
    def draw_cell(sz_x, sz_y, x, y)
      cell = @win.subwin(sz_y, sz_x, y, x)
      cell.box(VERTICAL_DIVIDER_CHR, HORIZONTAL_DIVIDER_CHR)
      draw_corners(cell, CORNER_CHR, sz_x, sz_y)
    end

    def draw_corners(cell, char, sz_x, sz_y)
      corners = [0, sz_x-1].product [0, sz_y-1]
      corners.each do |x,y|
        cell.setpos(y,x)
        cell.addch(char)
      end
    end

    def winloop
      x_start, y_start = CURSOR_START_X, CURSOR_START_Y
      x_step, y_step = SPACE_SIZE_X - 1, SPACE_SIZE_Y - 1
      x_bound, y_bound = [x_step, y_step].map{|i| i * @board.side_length}
      @win.keypad(true)
      Curses.noecho
      @win.setpos(y_start, x_start)
      @running = true
      while @running do
        key = @win.getch
        case key
        when Curses::KEY_LEFT
          @win.setpos(@win.cury, [x_start, (@win.curx - x_step) % x_bound].max)
        when Curses::KEY_RIGHT
          @win.setpos(@win.cury, [x_start, (@win.curx + x_step) % x_bound].max)
        when Curses::KEY_UP
          @win.setpos([y_start, (@win.cury - y_step) % y_bound].max, @win.curx)
        when Curses::KEY_DOWN
          @win.setpos([y_start, (@win.cury + y_step) % y_bound].max, @win.curx)
        when 27 # This corresponds to ESC or Alt+A
          @running = false
        else
          if key =~ /[[:alpha:]]/
            cap_letter = (key.capitalize == "Q" ? "Qu" : key.capitalize)
            @win.addstr(cap_letter)
            @win.setpos(@win.cury, @win.curx - cap_letter.size)
          end
        end
      end
    end
    
    # =========================================
    # Board Configurations
    # =========================================

    CURSOR_START_X = 2
    CURSOR_START_Y = 1
    SPACE_SIZE_X = 6
    SPACE_SIZE_Y = 3

    CORNER_CHR = "+"
    HORIZONTAL_DIVIDER_CHR = "-"
    VERTICAL_DIVIDER_CHR = "|"

  end
end
