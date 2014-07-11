require 'io/console'

module Upwords
  class Game

    attr_reader :players

    DIRECTION_KEYMAP= {
      'w' => [-1, 0], # up
      's' => [ 1, 0], # down
      'a' => [ 0,-1], # left 
      'd' => [ 0, 1]  # right
    } 
    DIRECTION_KEYMAP.default = [0,0]

    def initialize
      @board = Board.new
      @graphics = Graphics.new(@board)
      @players = Array.new

      # for testing only - uncomment 'add_players' for production version
      # add_players
      add_player("Max")    
      add_player("Jordan")

      @turn = 0
      @running = true
      @cursor_mode = true
      @submitted = false
    end

    def run
      while @running do
        hud_to_console
        begin
          cursor_loop
          input_loop
          next_turn
        rescue IllegalMove => exception
          print exception.message
        end
      end
    end

    def cursor_loop
      while @cursor_mode and !@submitted do 
        inp = STDIN.getch
        if !read_key_input(inp)
          move_cursor(DIRECTION_KEYMAP[inp])
        end
        hud_to_console
      end
    end

    def input_loop
      while !@cursor_mode and !@submitted do
        inp = STDIN.getch
        if !read_key_input(inp)
          letter = inp
          current_player.play_letter(letter)
        end
        hud_to_console
      end
    end
    
    def next_turn
      if @submitted then
        @turn = (@turn + 1) % player_count
        @submitted = false
      end
    end

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
      if player_count == max_players # TODO: Should I assert that count is never > max?
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

    def move_cursor(direction)
      @board.move_cursor(direction[0], direction[1])
    end

    def toggle_mode_key
      '1'
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
    
    def submit_key
      '2'  
    end

    def read_key_input(inp)
      is_action = false
      if inp == toggle_mode_key
        toggle_cursor_mode
        is_action = true
      elsif inp == submit_key
        submit
        is_action = true
      end
      is_action
    end
    
    def hud_to_console
      @graphics.draw_board
      print "#{current_player.name}'s letters: #{current_player.show_rack}\n"
      if @cursor_mode
        print "*CURSOR MODE* Use (WASD keys) to move around\n"
      elsif
        print "*INPUT MODE* Play a letter...\n"
      end
      print "Other actions: (1)Switch Modes (2)Submit (3)Swap (4)Skip\n"
    end
    
  end
end
