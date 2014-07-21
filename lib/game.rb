require 'io/console'

module Upwords
  class Game

    attr_reader :players

    def initialize
      @board = Board.new
      @players = Array.new
      @turn = 0
      
      @graphics = Graphics.new(self, @board)

      # add_players # LIVE CODE
      add_player("Max") # TEST CODE
      add_player("Jordan") # TEST CODE

      @running = true
      @submitted = false
    end

    # =========================================
    # Helper Methods
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
        if name.nil? or name.size < 1
          name += "Player #{player_count + 1}" 
        end
        @players << Player.new(@board, name)
      end
    end

    def add_players
      while player_count < max_players do
        print "What is Player #{player_count + 1}'s name?\n"
        player_name = gets.chomp
        add_player(player_name)
        print "\n"
      end
    end

    def display
      @graphics.draw_board(@turn)
      print "Use SHIFT + WASD keys to move cursor\n"
      print "Other actions: (1)Undo Moves (2)Submit (3)Swap (4)Skip\n"
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
          print exception.message
        end
      end
    end

    def input_loop
      while !@submitted do
        inp = STDIN.getch
        if key_is_action?(inp)
          instance_eval(&ACTION_KEYMAP[inp])     
        else
          if key_is_direction?(inp)
            current_player.move_cursor(DIRECTION_KEYMAP[inp])
          else
            current_player.play_letter(inp)
          end
        end
        display
      end
    end
    
    def next_turn
      if @submitted
        current_player.refill_rack
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

    # =========================================
    # Game Procedures Bound to some Key Input
    # =========================================

    def undo_moves
      current_player.undo_moves
    end

    def submit_moves
      print "Confirm submission? (y/n) "
      inp = gets.chomp
      if inp == 'y' or inp == 'Y'
        if current_player.submitted_moves?
          current_player.submit_moves
          @submitted = true
        else
          @graphics.message = "You haven't played any letters!\n"
        end
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
      '2' => proc { submit_moves }
    }

  end
end
