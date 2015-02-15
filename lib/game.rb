require 'io/console'
require 'curses'

module Upwords
  class Game

    attr_reader :board, :dictionary, :moves, :players

    def initialize(player1 = nil, player2 = nil, use_curses = false)
      @use_curses = use_curses
      @board = Board.new
      @dictionary = Dictionary.new("data/ospd.txt")
      @moves = Moves.new(self)
      @graphics = Graphics.new(self)
      # TODO: Remove the If block after testing is complete
      # Client should not be able to supply players to game
      # directly...
      if (player1.nil? || player2.nil?)
        add_players
      else
        add_player(player1)
        add_player(player2)
      end
      
      @turn = 0
      @running = true
      @submitted = false
    end
    
    # =========================================
    # Player Methods
    # =========================================

    def current_player
      @players[@turn]
    end

    def max_players
      2
    end

    def player_count
      player_count = @players.size
    end

    def add_player(name = nil)
      if player_count >= max_players
        raise StandardError, "No more players can join"
      else
        if name.nil? || name.size < 1
          name = "Player #{player_count + 1}" 
        end
        @players << Player.new(self, name)
      end
    end

    def add_players
      @players = Array.new
      while player_count < max_players do
        print "What is Player #{player_count + 1}'s name?\n"
        add_player(gets.chomp)
        print "\n"
      end
    end

    # =========================================
    # Graphics Methods
    # =========================================
    
    def refresh_graphics
      @graphics.draw_board
      print "Use SHIFT + WASD keys to move cursor\n"
      print "Other actions: (1)Undo Moves (2)Submit (3)Swap (4)Skip (5)Quit\n"
    end

    def update_message msg
      @graphics.message = msg
      refresh_graphics
    end

    def clear_message
      update_message ""
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

    def draw_grid(dim,sz_y,sz_x,y,x)
      (0...dim).each do |j|
        (0...dim).each do |i|
          swin = draw_subwin(@win, sz_y, sz_x, y+j*(sz_y-1), x+i*(sz_x-1))
          swin.box("|", "-")
          # make corners '+' (plus-signs)
          corners = [[0,0],[sz_y-1,0],[0,sz_x-1],[sz_y-1,sz_x-1]]
          corners.each do |y,x|
            swin.setpos(y,x)
            swin.addch("+")
          end
        end
      end
      @win.setpos(y,x)
    end

    # TODO: make this a private method ?
    def draw_subwin(win, sz_y,sz_x,y,x)
      win.subwin(sz_y,sz_x,y,x)    
    end

    def winloop
      @win.keypad(true)
      Curses.noecho
      @win.setpos(1,2)
      @running = true
      while @running do
        key = @win.getch
        case key
        when Curses::KEY_LEFT
          @win.setpos(@win.cury, @win.curx-5)
        when Curses::KEY_RIGHT
          @win.setpos(@win.cury, @win.curx+5)
        when Curses::KEY_UP
          @win.setpos(@win.cury-2, @win.curx)
        when Curses::KEY_DOWN
          @win.setpos(@win.cury+2, @win.curx)
        when 27 # This corresponds to ESC or Alt+A
          @running = false
        else
          if key =~ /[[:alpha:]]/
            cap_letter = (key.capitalize == "Q" ? "Qu" : key.capitalize)
            @win.addstr(cap_letter)
            @win.setpos(@win.cury, @win.curx - cap_letter.size)
          end
        end
        @win.refresh  
      end
    end

    # =========================================
    # Game Loops & Non-Input Procedures
    # =========================================

    def run
      # new Curses window subroutine (STILL BEING IMPLEMENTED!)
      if @use_curses
        open_window
        draw_grid(10,3,6,0,0)
        winloop
        close_window
      # old basic console subroutine
      else
        ARGV.clear
        while @running do
          refresh_graphics
          begin
            input_loop
            next_turn
          rescue IllegalMove => exception
            update_message exception.message
          end
        end
      end
    end

    def input_loop
      while !@submitted && @running do
        inp = STDIN.getch
        clear_message
        if key_is_action?(inp)
          instance_eval(&ACTION_KEYMAP[inp])     
        elsif key_is_direction?(inp)
          current_player.move_cursor(DIRECTION_KEYMAP[inp])
        else
          current_player.play_letter(inp)
          update_message "Pending words: #{current_player.show_pending_moves}"
        end
        refresh_graphics
      end
    end
    
    def next_turn
      if @submitted
        # TODO: add subroutine to end game if letter bank is empty and either player has exhausted all their letters
        # TODO: add subroutine to end game if both players skipped 3 consecutive turns (check rules to see exactly how this works...)
        @turn = (@turn + 1) % player_count
        @submitted = false
      end
    end

    # =========================================
    # Methods Related to Key Inputs
    # =========================================

    def key_is_action?(inp)
      ACTION_KEYMAP.keys.include?(inp)
    end

    def key_is_direction?(inp)
      DIRECTION_KEYMAP.keys.include?(inp)
    end

    def confirm_action?(question_text)
      update_message "#{question_text} (y/n)"
      inp = STDIN.getch
      clear_message
      inp == 'y' || inp == 'Y'
    end

    # =========================================
    # Game Procedures Bound to some Key Input
    # =========================================

    def undo_moves
      if !current_player.has_pending_moves?
        raise IllegalMove, "No moves to undo!"
      elsif confirm_action? "Are you sure you want to undo?"
        current_player.undo_moves 
      end
    end

    def submit_moves
      if !current_player.has_pending_moves?
        raise IllegalMove, "You haven't played any letters!"
      elsif confirm_action? "Are you sure you want to submit?"
        current_player.submit_moves
        @submitted = true
      end
    end

    # TODO: Test this method...
    def swap_letter
      update_message "Pick a letter to swap... "
      letter = STDIN.getch
      if confirm_action? "Swap '#{letter}' for another?"
        current_player.swap_letter(letter)
        @submitted = true
      end
    end

    def skip_turn
      if confirm_action? "Are you sure you want to skip your turn?"
        current_player.undo_moves
        @submitted = true
      end
    end

    def exit_game
      if confirm_action? "Are you sure you want to exit the game?"
        @running = false
      end
    end

    # =========================================
    # Key Configurations
    # =========================================
    
    DIRECTION_KEYMAP = {
      'W' => [-1, 0], # up
      'S' => [ 1, 0], # down
      'A' => [ 0,-1], # left 
      'D' => [ 0, 1]  # right
    } 
    DIRECTION_KEYMAP.default = [0,0]

    ACTION_KEYMAP = {
      '1' => proc { undo_moves },
      '2' => proc { submit_moves },
      '3' => proc { swap_letter },
      '4' => proc { skip_turn },
      '5' => proc { exit_game }
    }

  end
end
