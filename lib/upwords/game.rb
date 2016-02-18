require 'curses'

module Upwords
  class Game
    attr_reader :board, :dictionary, :letter_bank, :moves, :players
    
    # =========================================
    # Key Configurations
    # =========================================
    
    DIRECTION_KEYMAP = {
      Curses::KEY_UP    => [-1, 0], # up
      Curses::KEY_DOWN  => [ 1, 0], # down
      Curses::KEY_LEFT  => [ 0,-1], # left 
      Curses::KEY_RIGHT => [ 0, 1]  # right
    }

    ACTION_KEYMAP = {
      '1' => proc { undo_moves },
      '2' => proc { submit_moves },
      '3' => proc { swap_letter },
      '4' => proc { skip_turn },
      '5' => proc { exit_game },
      '0' => proc { toggle_rack_visibility }
    }

    # =========================================
    # Data
    # =========================================
    
    # Letters available in 10 x 10 version of Upwords
    ALL_LETTERS = (["E"]*8 +
                   ["A", "I", "O"]*7 +
                   ["S"]*6 +
                   ["D", "L", "M", "N", "R", "T", "U"]*5 +
                   ["C"]*4 +
                   ["B", "F", "G", "H", "P"]*3 +
                   ["K", "W", "Y"]*2 +
                   ["J", "Qu", "V", "X", "Z"]*1)
    
    
    def initialize(player1 = nil, player2 = nil, display = true)
      @display = display
      @board = Board.new
      @letter_bank = LetterBank.new(ALL_LETTERS)
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

      # Init curses
      if @display
        init_window
      end
      
      @running = false
      @submitted = false
    end
    
    # =========================================
    # Player Methods
    # =========================================

    def current_player
      @players.first
    end

    def max_players
      2
    end

    def player_count
      player_count = @players.size
    end

    def add_player(name = nil)
      @players ||= Array.new
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
      @players ||= Array.new
      while player_count < max_players do
        print "What is Player #{player_count + 1}'s name?\n"
        add_player(gets.chomp)
        print "\n"
      end
    end

    # =========================================
    # Graphics Methods
    # =========================================

    def init_window
      Curses.noecho
      Curses.curs_set(0)
      Curses.init_screen
      Curses.start_color
      @win = Curses::Window.new(0,0,0,0)
      @win.keypad(true)
    end
    
    def display?
      @display
    end
    
    def refresh_graphics
      if display? && running?
        @win.clear
        @win << @graphics.to_s
        @win.refresh
      end
    end

    def update_message msg
      if display?
        @graphics.message = msg
        refresh_graphics
      end
    end

    def clear_message
      update_message standard_message
    end

    def standard_message
      "Actions: (1)Undo Moves (2)Submit (3)Swap (4)Skip (5)Quit\n"
    end
    
    # =========================================
    # Game Loops & Non-Input Procedures
    # =========================================

    def running?
      @running
    end

    def run
      @running = true
      clear_message
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

    def input_loop
      while !@submitted && @running do
        inp = @win.getch #STDIN.getch
        clear_message
        if key_is_action?(inp)
          instance_eval(&ACTION_KEYMAP[inp])     
        elsif key_is_direction?(inp)
          current_player.move_cursor(DIRECTION_KEYMAP.fetch(inp, [0,0]))
        elsif inp =~ /[[:alpha:]]/
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
        @players.rotate!
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
      if display?
        update_message "#{question_text} (y/n)"
        inp = @win.getch
        clear_message
        inp == 'y' || inp == 'Y'
      else
        true # Never ask for confirm if the display is off
      end
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
      letter = @win.getch #STDIN.getch
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

    def exit_game(need_confirm=true)
      if confirm_action? "Are you sure you want to exit the game?"
        @running = false
        @win.close
      end
    end

    def toggle_rack_visibility(need_confirm=true)
      if confirm_action? "Change rack visibility?"
        @graphics.toggle_rack_visibility
      end
    end

  end
end
