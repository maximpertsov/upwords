module Upwords
  class Game

    attr_reader :players

    def initialize
      @board = Board.new
      @players = Array.new(max_players)

      # add players
      @players.each do |p|
        print "What is Player #{player_count + 1}'s name?\n"
        p_name = gets.chomp
        add_player(p_name)
      end

      @turn = 0
      @running = true
    end

    def run
      while @running do
        begin 
          print "\n"
          @board.show
          print "\n#{current_player.name}'s turn\n"
          print "Available letters: #{current_player.show_rack}\n"
          print "Play a letter...\n"
          letter = gets.chomp
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

    def add_player(name = nil)
      if player_count == max_players # can I assert than player_count should never be > max_players
        raise StandardError, "No more players can join"
      else
        # if no name is entered, name will be "Player#"
        if name.nil? then name += "Player #{player_count + 1}" end
        @players[player_count] = Player.new(@board, name)
      end
    end
  end
end
