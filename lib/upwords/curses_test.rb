require 'curses'

def winloop(win)
  win.keypad(true)
  Curses.noecho
  win.setpos(1,2)
  running = true
  while running do
    key = win.getch
    case key
    when Curses::KEY_LEFT
      win.setpos(win.cury, win.curx-5)
    when Curses::KEY_RIGHT
      win.setpos(win.cury, win.curx+5)
    when Curses::KEY_UP
      win.setpos(win.cury-2, win.curx)
    when Curses::KEY_DOWN
      win.setpos(win.cury+2, win.curx)
    when 27 # This corresponds to ESC or Alt+A
      running = false
    else
      if key =~ /[[:alpha:]]/
        cap_letter = (key.capitalize == "Q" ? "Qu" : key.capitalize)
        win.addstr(cap_letter)
        win.setpos(win.cury, win.curx - cap_letter.size)
      end
    end
    win.refresh  
  end
end

def make_subwin(win,sz_y,sz_x,y,x)
  win.subwin(sz_y,sz_x,y,x)    
end

def make_grid(win,dim,sz_y,sz_x,y,x)
  (0...dim).each do |j|
    (0...dim).each do |i|
      swin = make_subwin(win, sz_y, sz_x, y+j*(sz_y-1), x+i*(sz_x-1))
      swin.box("|", "-")
      # make corners '+' (plus-signs)
      corners = [[0,0],[sz_y-1,0],[0,sz_x-1],[sz_y-1,sz_x-1]]
      corners.each do |y,x|
        swin.setpos(y,x)
        swin.addch("+")
      end
    end
  end
  win.setpos(y,x)
end

Curses.init_screen
Curses.start_color

Curses.init_pair(Curses::COLOR_GREEN,Curses::COLOR_GREEN,Curses::COLOR_WHITE)

win = Curses::Window.new(0,0,0,0)
#win.setpos(1,2)
# Example of setting colors
# win.attron(Curses.color_pair(Curses::COLOR_GREEN)|Curses::A_NORMAL){
#  win.addstr("I blue myself")
#}
make_grid(win,10,3,6,0,0)
winloop(win)
win.close
