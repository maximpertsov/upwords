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

    def play_letter(letter)
      selected_letter = @rack.take_from(letter)
      begin
        @board.play_letter(selected_letter)
      rescue IllegalMove => exception
        print exception.message
        @rack.return_to(selected_letter)
      end
    end

    def swap_letter(letter)
      @rack.swap(letter)
    end

    def refill_rack
      @rack.refill
    end
    
  end
end
