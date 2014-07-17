require 'io/console'

module Upwords
  class Game

    attr_reader :players

    def initialize
      @board = Board.new
      # @submit_grid = Array.new(num_rows) {Array.new(num_columns) {true}}
      # @pending_moves = Array.new
      @graphics = Graphics.new(@board)
      @players = Array.new

      add_players # LIVE CODE
      # add_player("Max") # TEST CODE
      # add_player("Jordan") # TEST CODE

      @turn = 0
      @running = true
      @cursor_mode = true
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
      @graphics.draw_board
      print "#{current_player.name}'s letters: #{current_player.show_rack}\n"
      if @cursor_mode
        print "*CURSOR MODE* Use (WASD keys) to move around\n"
      elsif
        print "*INPUT MODE* Play a letter...\n"
      end
      print "Other actions: (1)Switch Modes (2)Submit (3)Swap (4)Skip\n"
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
          if @cursor_mode
            move_cursor(DIRECTION_KEYMAP[inp])
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

    # =========================================
    # Game Procedures Bound to some Key Input
    # =========================================
    
    def move_cursor(direction)
      @board.move_cursor(direction[0], direction[1])
    end

    def toggle_cursor_mode
      @cursor_mode = !@cursor_mode
    end

    def submit
      print "Confirm submission? (y/n) "
      inp = gets.chomp
      if inp == 'y' or inp == 'Y'
        @submitted = true
      end
    end

    # =========================================
    # Key Configurations
    # =========================================
    
    DIRECTION_KEYMAP = {
      'w' => [-1, 0], # up
      's' => [ 1, 0], # down
      'a' => [ 0,-1], # left 
      'd' => [ 0, 1]  # right
    } 
    DIRECTION_KEYMAP.default = [0,0]

    ACTION_KEYMAP = {
      '1' => proc { toggle_cursor_mode },
      '2' => proc { submit }
    }

  end
end
