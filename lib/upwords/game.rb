module Upwords
  class Game
    attr_reader :board, :players
        
    def initialize(display_on = true, max_players = 2)
      @max_players = max_players
      @display_on = display_on
      @board = Board.new(10)
      @letter_bank = LetterBank.new(ALL_LETTERS.dup)
      @cursor = Cursor.new(@board.num_rows,
                           @board.num_columns,
                           *@board.middle_square[0])
      @moves = MoveManager.new(@board,
                               Dictionary.import(OSPD_FILE))
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

      @win = Graphics.new(self, @cursor)
      @win.keypad(true)
    end
    
    def display_on?
      @display_on
    end
    
    def refresh_graphics
      if display_on? && running?
        @win.refresh
      end
    end

    def update_message msg
      if display_on?
        @win.message = msg
        refresh_graphics
      end
    end

    def clear_message
      update_message standard_message
    end

    # TODO: move text parsing logic out of MoveManager's pending_result method
    def standard_message
      ["#{current_player.name}'s pending words: #{pending_result}",
       "",
       "Controls",
       "--------",
       "Show Letters\t[SPACE]",
       "Undo Moves\t[DEL]",
       "Submit Move\t[ENTER]",
       "Swap Letter\t[+]",
       "Skip Turn\t[-]",
       "Quit Game\t[ESC] or [SHIFT+Q]"
      ].join("\n")
    end

    def pending_result
      new_words = @moves.pending_words

      unless new_words.empty?
        new_words.map do |w|
          "#{w} (#{w.score})"
        end.join(", ") + " (Total = #{@moves.pending_score})"
      end
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
      @players.each {|p| p.refill_rack(@letter_bank) }

      # Start graphics
      init_window #if @display_on
      clear_message

      # Start main loop
      while running? do
        begin
          read_input(@win.getch)

          # TODO: add subroutine to end game if letter bank is empty and either player has exhausted all their letters
          # TODO: add subroutine to end game if all players skip turn consecutively (check rules to see exactly how this works)

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
          update_message "#{exception.message} (press any key to continue...)"
          @win.getch
          clear_message
        end
      end
    end

    def read_input(key)
      case key
      when ESCAPE
        exit_game
      when 'Q'
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
      @players.rotate!
      @win.hide_rack
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
      clear_message
    end

    def submit_moves
      if confirm_action? "Are you sure you want to submit?"
        @moves.submit(current_player)
        current_player.refill_rack(@letter_bank)
        @submitted = true
        clear_message
        
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
          current_player.swap_letter(letter, @letter_bank)
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
      @win.toggle_rack_visibility
    end
  end
end
