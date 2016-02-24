module Upwords
  class Game
    attr_reader :board, :players
    
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
      #@letter_bank = LetterBank.new(ALL_LETTERS)
      @cursor = Cursor.new(@board.num_rows,
                           @board.num_columns,
                           *@board.middle_square[0])
      @moves = MoveManager.new(@board,
                               Dictionary.import("data/ospd.txt"),
                               LetterBank.new(ALL_LETTERS))
                               #@board.middle_square[0])
      @graphics = Graphics.new(self, @cursor)
      
      # TODO: Remove the If block after testing is complete
      # Client should not be able to supply players to game
      # directly...
      if (player1.nil? || player2.nil?)
        add_players
      else
        add_player(player1)
        add_player(player2)
      end

      # Each player fills their letter rack...
      @players.each {|p| @moves.refill_rack(p) }

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
        @players << Player.new(name, rack_capacity=7) #, init_cursor_posn=@board.middle_square[0])
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

    # UGLY: Aligned second line by measuring 'Actions: '
    def standard_message
      "Actions: (1)Undo Moves (2)Submit (3)Swap (4)Skip (5)Quit\n#{' ' * 'Actions: '.size}(0)Show Letters"
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
      while running? do
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
      while !@submitted && running? do
        inp = @win.getch
        clear_message
        if key_is_action?(inp)
          instance_eval(&ACTION_KEYMAP[inp])     
        elsif key_is_direction?(inp)
          @cursor.move(*DIRECTION_KEYMAP.fetch(inp, [0,0]))
        elsif inp =~ /[[:alpha:]]/
          @moves.add(current_player,
                     modify_letter_input(inp),
                     @cursor.y,
                     @cursor.x)
          update_message "Pending words: #{@moves.pending_result}"
        end
        refresh_graphics
      end
    end
    
    def next_turn
      if @submitted
        # TODO: add subroutine to end game if letter bank is empty and either player has exhausted all their letters
        # TODO: add subroutine to end game if both players skipped 3 consecutive turns (check rules to see exactly how this works...)
        @players.rotate!
        @graphics.hide_rack
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

    # Capitalize letters, and convert 'Q' and 'q' to 'Qu'
    def modify_letter_input(letter)
      if letter =~ /[Qq]/
        'Qu'
      else
        letter.capitalize
      end
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
      @moves.undo_last(current_player)
      update_message "Pending words: #{@moves.pending_result}"
    end

    def submit_moves
      if confirm_action? "Are you sure you want to submit?"
        @moves.submit(current_player)
        @submitted = true
      end
    end

    # TODO: Test this method...
    def swap_letter
      update_message "Pick a letter to swap... "
      letter = @win.getch

      if letter =~ /[[:alpha:]]/
        letter = modify_letter_input(letter)
        if confirm_action? "Swap '#{letter}' for another?"
          @moves.undo_all(current_player)
          @moves.swap_letter(current_player, letter)
          @submitted = true
        end
      end
    end

    def skip_turn
      if confirm_action? "Are you sure you want to skip your turn?"
        @moves.undo_all(current_player)
        @submitted = true
      end
    end

    def exit_game(need_confirm=true)
      if confirm_action? "Are you sure you want to exit the game?"
        @running = false
        @win.close
      end
    end

    def toggle_rack_visibility #(need_confirm=true)
      @graphics.toggle_rack_visibility
    end
  end
end
