require 'io/console'

module Upwords
  class Game

    attr_reader :players

    Controls = {
      'w' => [-1, 0], #up
      's' => [ 1, 0], #down
      'a' => [ 0,-1], #left 
      'd' => [ 0, 1]  #right
    } 

    def initialize
      @board = Board.new
      @players = Array.new(max_players)

      # add players
      @players.each do |p|
        print "What is Player #{player_count + 1}'s name?\n"
        player_name = gets.chomp
        add_player(player_name)
        print "\n"
      end

      @turn = 0
      @running = true
      @cursor_mode = true
    end

    def run
      while @running do
        begin 
          hud_to_console
          
          while @cursor_mode do
            inp = STDIN.getch
            move_cursor(Controls[inp])
            hud_to_console
          end
          
          letter = gets.chomp
          # letter = STDIN.getch ## get input without letter without pressing enter
          current_player.play_letter(letter)
          current_player.refill_rack
          next_turn
        rescue IllegalMove => exception
          print exception.message
        end
      end
    end

    def next_turn
      @turn = (@turn + 1) % max_players
    end

    def current_player
      @players[@turn]
    end

    def max_players
      2
    end

    def player_count
      player_count = @players.compact.size
    end

    def move_cursor(direction)
      @board.update_cursor_location(direction[0], direction[1])
    end

    def add_player(name = nil)
      if player_count == max_players # can I assert than player_count should never be > max_players
        raise StandardError, "No more players can join"
      else
        # if no name is entered, name will be "Player#"
        if name.nil? then name += "Player #{player_count + 1}" end
        @players[player_count] = Player.new(@board, name)
      end
    end
    
    def hud_to_console
      @board.show_in_console
      print "#{current_player.name}'s letters: #{current_player.show_rack}\n"
      print "Use (WASD keys) to move around\n"
      print "Other actions: (1)Play Letter (2)Submit (3)Swap (4)Skip\n"
    end

  end
end
