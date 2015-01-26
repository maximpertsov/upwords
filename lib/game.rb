require 'io/console'

module Upwords
  class Game

    attr_reader :players

    def initialize(player1 = nil, player2 = nil)
      @board = Board.new
      @graphics = Graphics.new(self, @board)
      @dictionary = Dictionary.new("data/ospd.txt")
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
        @players << Player.new(@board, name, @dictionary)
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
    
    def display
      @graphics.draw_board
      print "Use SHIFT + WASD keys to move cursor\n"
      print "Other actions: (1)Undo Moves (2)Submit (3)Swap (4)Skip (5)Quit\n"
    end

    def update_message msg
      @graphics.message = msg
    end

    # =========================================
    # Game Loops & Non-Input Procedures
    # =========================================

    def run
      while @running do
        display
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
        inp = STDIN.getch
        update_message ""
        if key_is_action?(inp)
          instance_eval(&ACTION_KEYMAP[inp])     
        elsif key_is_direction?(inp)
          current_player.move_cursor(DIRECTION_KEYMAP[inp])
        else
          current_player.play_letter(inp)
          update_message "Pending words: #{current_player.show_pending_moves}"
        end
        display
      end
    end
    
    def next_turn
      if @submitted
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
      print "#{question_text} (y/n) " # TODO: Make this update_message instead of print
      inp = STDIN.getch
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
      print "Pick a letter to swap... "
      letter = STDIN.getch
      if confirm_action? "Swap '#{letter}' for another?"
        current_player.swap_letter(letter)
        @submitted = true
      end
    end

    def skip_turn
      if confirm_action? "Are you sure you want to skip your turn?"
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
