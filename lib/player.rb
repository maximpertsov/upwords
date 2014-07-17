module Upwords
  class Player

    attr_reader :name, :score, :cursor_posn

    def initialize(board, player_name)
      @name = player_name
      @board = board
      @rack = LetterRack.new(board.letter_bank)
      @score = 0
      @cursor_posn = [0, 0]
    end

    def show_rack
      @rack.show
    end

    def move_cursor(move_vector)
      max_move = [@board.num_rows, @board.num_columns]
      move_vector.each_with_index do |move, idx|
        @cursor_posn[idx] = (@cursor_posn[idx] + move) % max_move[idx]
      end 
    end

    def play_letter(letter)
      selected_letter = @rack.take_from(letter)
      begin
        @board.play_letter(selected_letter, @cursor_posn[0], @cursor_posn[1])
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
