module Upwords
  class Game
    attr_reader :board, :players
    
    # =========================================
    # Key Configurations
    # =========================================

    ESCAPE = 27    # Should already be in a Curses constant...
    SPACE = ' '
    DELETE = 127
    ENTER = 10

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
    
    
    def initialize(display_on = true, max_players = 2)
      @max_players = max_players
      @display_on = display_on
      @board = Board.new
      @letter_bank = LetterBank.new(ALL_LETTERS)
      @cursor = Cursor.new(@board.num_rows,
                           @board.num_columns,
                           *@board.middle_square[0])
      @moves = MoveManager.new(@board,
                               Dictionary.import("data/ospd.txt"),
                               @letter_bank)
      @graphics = Graphics.new(self, @cursor)
      @players = []
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
      @max_players
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
        @players << Player.new(name, rack_capacity=7)
      end
    end

    def add_players(player_names = nil)
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
      # Curses.start_color
      @win = Curses::Window.new(0,0,0,0)
      @win.keypad(true)
    end
    
    def display_on?
      @display_on
    end
    
    def refresh_graphics
      if display_on? && running?
        @win.clear
        @win << @graphics.to_s
        @win.refresh
      end
    end

    def update_message msg
      if display_on?
        @graphics.message = msg
        refresh_graphics
      end
    end

    def clear_message
      update_message standard_message
    end

    def standard_message
      ["Pending words: #{@moves.pending_result}",
       "",
       "Controls",
       "--------",
       "[SPACE]\tShow Letters",
       "[DEL]\tUndo Moves",
       "[ENTER]\tSubmit",
       "[+]\tSwap Letter",
       "[-]\tSkip Turn",
       "[ESC]\tQuit Game"
      ].join("\n")
    end
    
    # =========================================
    # Game Loops & Non-Input Procedures
    # =========================================

    def running?
      @running
    end

    def run
      @running = true
      # Add players
      add_players
      @players.each {|p| @moves.refill_rack(p) }

      # Start graphics
      init_window if @display_on
      clear_message

      # Start main loop
      while running? do
        begin
          read_input

          # Game over check
          if current_player.skip_count == 3
            update_message "#{current_player.name} has skipped 3 times in a row and loses!"
            @running = false
          elsif @letter_bank.empty? && current_player.rack_empty?

            # TODO: 
            # multiply remaining letter x 5 and add to current player score
            # player with the higher score wins
            @running = false
            
          elsif @submitted
            next_turn
          end
          
          refresh_graphics
        rescue IllegalMove => exception
          update_message exception.message
          @win.getch
          clear_message
        end
      end
    end

    def read_input
      case (key = @win.getch)
      when ESCAPE
        exit_game
      when SPACE
        toggle_rack_visibility
      when DELETE
        undo_moves
      when ENTER
        submit_moves
      when Curses::KEY_UP
        @cursor.up
      when Curses::KEY_DOWN
        @cursor.down
      when Curses::KEY_LEFT
        @cursor.left
      when Curses::KEY_RIGHT
        @cursor.right
      when '+'
        swap_letter
      when '-'
        skip_turn
      when /[[:alpha:]]/
        @moves.add(current_player, modify_letter_input(key), @cursor.y, @cursor.x)
        clear_message
      end
    end
    
    def next_turn
        # TODO: add subroutine to end game if letter bank is empty and either player has exhausted all their letters
        # TODO: add subroutine to end game if both players skipped 3 consecutive turns (check rules to see exactly how this works...)
      @players.rotate!
      @graphics.hide_rack
      @submitted = false
    end

    # =========================================
    # Methods Related to Key Inputs
    # =========================================

    # Capitalize letters, and convert 'Q' and 'q' to 'Qu'
    def modify_letter_input(letter)
      if letter =~ /[Qq]/
        'Qu'
      else
        letter.capitalize
      end
    end

    def confirm_action?(question_text)
      if display_on?
        update_message "#{question_text} (y/n)"
        inp = @win.getch
        clear_message
        inp == 'y' || inp == 'Y'
      else
        true # Never ask for confirm if the display_on is off
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

        # HACK: think of a better way to decrement skip count...
        current_player.skip_count = 0
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

          # HACK: think of a better way to decrement skip count...
          current_player.skip_count = 0
        end
      end
    end

    def skip_turn
      if confirm_action? "Are you sure you want to skip your turn?"
        @moves.undo_all(current_player)
        current_player.skip_count += 1
        @submitted = true
      end
    end

    def exit_game(need_confirm=true)
      if confirm_action? "Are you sure you want to exit the game?"
        @running = false
        @win.close if display_on?
      end
    end

    def toggle_rack_visibility #(need_confirm=true)
      @graphics.toggle_rack_visibility
    end
  end
end
