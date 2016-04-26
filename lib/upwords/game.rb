module Upwords
  class Game
    attr_reader :board, :cursor, :players
    
    def initialize(max_players = 4)
      @max_players = max_players
      @board = Board.new(10, 5)
      @letter_bank = LetterBank.new(ALL_LETTERS.dup)
      @cursor = Cursor.new(@board.num_rows, @board.num_columns, *@board.middle_square[0])
      @dict = Dictionary.import(OSPD_FILE)
      @moves = MoveManager.new(@board, @dict)
      @players = []
      @running = true
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

    def add_player(name = nil, letter_capacity = 7, cpu = false)
      raise ArgumentError, "No more players can join" if player_count >= max_players
      
      # Automatically name player if no name is provided
      name = "Player #{player_count + 1}" if name.nil? || name.length == 0
        
      @players << Player.new(name, letter_capacity, cpu)
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
        print "Is #{name.length > 0 ? name : sprintf('Player %d', idx)} a computer? (y/n)\n"
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

    def cpu_move
      move = current_player.cpu_move(@board, @dict, sample_size=50, min_score=10)      
      if !move.nil?
        move.each { |pos, letter| play_letter(letter, *pos) }
        submit_moves
      else
        skip_turn
      end
    end
    
    # =========================================
    # Game Procedures Bound to some Key Input
    # =========================================

    def submit_moves
      @moves.submit(current_player)
      current_player.refill_rack(@letter_bank)     
      current_player.last_turn = "played word"      # TODO: remove magic string from last move message
      next_turn
    end

    def swap_letter(letter)
      letter = modify_letter_input(letter)
      @moves.undo_all(current_player)
      current_player.swap_letter(letter, @letter_bank) 
      current_player.last_turn = "swapped letter"        # TODO: remove magic string from last move message
      next_turn
    end

    def skip_turn
      @moves.undo_all(current_player)
      current_player.last_turn = "skipped turn"    # TODO: remove magic string from last move message
      next_turn
    end

    def exit_game
      @running = false
    end

    # =================
    # Game over methods
    # =================
    
    def game_over?
      @players.all? {|p| p.last_turn == "skipped turn"} || (@letter_bank.empty? && current_player.rack_empty?)
    end

    def get_top_score
      @players.map {|p| p.score}.max
    end

    def get_winners
      @players.select{|p| p.score == get_top_score}.map{|p| p.name}
    end

    private 

    def next_turn
      if game_over?
        # Subtract 5 points for each tile remaining
        @players.each { |p| p.score -= p.letters.size * 5 }
      else    
        @players.rotate!
      end
    end

    # Capitalize letters, and convert 'Q' and 'q' to 'Qu'
    def modify_letter_input(letter)
      if letter =~ /[Qq]/
        'Qu'
      else
        letter.capitalize
      end
    end

  end
end
