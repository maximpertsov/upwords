module Upwords
  class PlayerManager
    
    def initialize(max_players = 2, *player_names)
      @max_players = max_players
      @players = []
      player_names.each {|name| add_player(name)}
    end

    def current_player
      @players.first
    end

    def max_players
      @max_players
    end

    def player_count
      @players.size
    end

    def rotate!
      @players.rotate!
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

  end
end
