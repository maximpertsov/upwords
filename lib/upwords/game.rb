module Upwords
  class Game
    attr_reader :board, :cursor, :players, :dict
    
    def initialize(display_on = true, max_players = 4)
      @max_players = max_players
      @display_on = display_on
      @board = Board.new(10, 5)
      @letter_bank = LetterBank.new(ALL_LETTERS.dup)
      @cursor = Cursor.new(@board.num_rows,
                           @board.num_columns,
                           *@board.middle_square[0])
      @dict = Dictionary.import(OSPD_FILE)
      @moves = MoveManager.new(@board, @dict)
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

    def add_player(name = nil, cpu = false)
      if player_count >= max_players
        raise StandardError, "No more players can join"
      else
        if name.nil? || name.size == 0
          name = "Player #{player_count + 1}" 
        end
        @players << Player.new(name, rack_capacity=7, cpu)
      end
    end

    def add_players(player_names = nil)
      print "\n"
      num_players = 0

      # Select how many players will be in the game
      # TODO: Add a command-line flag to allow players to skip this step
      until (1..@max_players).include?(num_players) do
        print "How many players will play? (1-#{@max_players})\n"
        num_players = gets.chomp.to_i
        print "\n"
        if !(1..@max_players).include?(num_players)
          print "Invalid selection: #{num_players}\n\n"
        end
      end

      # Name each player and choose if they are humans or computers
      # TODO: Add a command-line flag to set this
      (1..num_players).each do |idx|
        print "What is Player #{idx}'s name?\n"
        name = gets.chomp
        print "Is Player #{idx} or a computer? (y/n)\n"
        cpu = gets.chomp
        add_player(name, cpu.upcase == "Y")
        print "\n"
      end
    end

    def all_refill_racks
      @players.each {|p| p.refill_rack(@letter_bank) }
    end

    # =========================================
    # Move Manager Methods
    # =========================================
    
    def play_letter(letter, y = @cursor.y, x = @cursor.x)
      @moves.add(current_player, modify_letter_input(letter), y, x)
    end

    def undo_last
      @moves.undo_last(current_player)
    end

    def pending_position?(row, col)
      @moves.include?(row, col)
    end

    # =========================================
    # Graphics Methods - to be retired...
    # =========================================

    def init_window
      Curses.noecho
      Curses.curs_set(0) 
      Curses.init_screen
      # Curses.start_color

      @win = Graphics.new(self)
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

    def standard_message
      "#{current_player.name}'s pending words: #{pending_result}"
    end

    def pending_result
      new_words = @moves.pending_words

      unless new_words.empty?
        new_words.map do |w|
          "#{w} (#{w.score})".upcase
        end.join(", ") + " (Total = #{@moves.pending_score(current_player)})"
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
      all_refill_racks

      # Start graphics
      init_window if @display_on
      clear_message

      # Start main loop
      while running? do
        begin
          # ------ CPU MOVE --------
          if current_player.cpu?
            update_message "#{current_player.name} is thinking..."
            cpu_move = current_player.cpu_move(@board, @dict, 50, 10)
            
            if !cpu_move.nil?
              cpu_move.each do |posn, letter|
                play_letter(letter, *posn)
              end
              submit_moves(need_confirm=false)
            else
              skip_turn(need_confirm=false)
            end
          else
            read_input(@win.getch)
          end

          if @submitted
            # TODO: remove magic string from last move message
            if @players.all? {|p| p.last_turn == "skipped turn"} || @letter_bank.empty? && current_player.rack_empty?
              game_over
              @running = false
            else    
              next_turn
            end
          end
          
          refresh_graphics
          
        rescue IllegalMove => exception
          update_message "#{exception.message} (press any key to continue...)"
          @win.getch if display_on?
          clear_message
        end
      end
      
    end

    def read_input(key)
      case key
      when 'Q'
        exit_game
      when SPACE
        toggle_rack_visibility
      when DELETE
        undo_last
        clear_message
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
        play_letter(key)
        clear_message
      end
    end
    
    def next_turn
      @players.rotate!
      @win.hide_rack if display_on?
      clear_message
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

    def submit_moves(need_confirm=true)
      if !need_confirm || (confirm_action? "Are you sure you want to submit?")
        @moves.submit(current_player)
        current_player.refill_rack(@letter_bank)
        @submitted = true
        clear_message if display_on?

        # TODO: remove magic string from last move message
        current_player.last_turn = "played word"
      end
    end

    # TODO: Test this method...
    def swap_letter(need_confirm=true)
      update_message "Pick a letter to swap... "
      letter = @win.getch

      if letter =~ /[[:alpha:]]/
        letter = modify_letter_input(letter)
        if !need_confirm || (confirm_action? "Swap '#{letter}' for another?")
          @moves.undo_all(current_player)
          current_player.swap_letter(letter, @letter_bank)
          @submitted = true

          # TODO: remove magic string from last move message
          current_player.last_turn = "swapped letter"
        end
      end
    end

    def skip_turn(need_confirm=true)
      if !need_confirm || (confirm_action? "Are you sure you want to skip your turn?")
        @moves.undo_all(current_player)
        @submitted = true

        # TODO: remove magic string from last move message
        current_player.last_turn = "skipped turn"
      end
    end

    def exit_game(need_confirm=true)
      if !need_confirm || (confirm_action? "Are you sure you want to exit the game?")
        @running = false
        @win.close if display_on?
      end
    end

    def toggle_rack_visibility 
      @win.toggle_rack_visibility
    end

    def game_over
      update_message "The game is over. Press any key to continue to see who won..."
      @win.getch if display_on?

      # Subtract 5 points for each tile remaining
      @players.each do |p|
        p.score -= p.letters.size * 5
      end

      top_score = @players.map {|p| p.score}.max
      winners = @players.select{|p| p.score == top_score}.map{|p| p.name}

      if winners.size == 1 
        update_message "And the winner is... #{winners[0]} with #{top_score} points!"
      else
        update_message "We have a tie! #{winners.join(', ')} all win with #{top_score} points!"
      end

      @win.getch if display_on?
      exit_game(need_confirm=false)
    end

  end
end
