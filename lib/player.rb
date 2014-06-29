module Upwords
  class Player

    attr_reader :name, :score

    def initialize(board, player_name)
      @name = player_name
      @board = board
      @rack = LetterRack.new(board.letter_bank)
      @score = 0
    end

    def show_rack
      @rack.rack
    end

    def play_letter(letter, row, col)
      if !@rack.has_letter?(letter)
        raise IllegalMove, "You don't have this letter"
      else 
        @board.play_letter(letter, row, col)
      end
    end

    def swap_letter(letter)
      @rack.swap(letter)
    end
    
    ## Move to Game class
    def submit_move
      # Prompts player if they wish to submit their move
      # This method will be at the end of each move method
    end
  end
end
