module Upwords
  class Player

    attr_reader :name, :cursor_posn
    attr_accessor :score

    def initialize(game, player_name)
      @name = player_name
      @board = game.board
      @score = 0
      @cursor_posn = @board.middle_square[0]
      @letter_bank = game.letter_bank
      
      @rack = LetterRack.new(capacity=7)
      # refill_rack
    end

    def show_rack
      @rack.show
    end

    def show_hidden_rack
      @rack.show_masked
    end

    def take_letter(letter)
      @rack.add(letter)
    end

    def play_letter(letter)
      MoveUnit.new(@rack.remove(letter), *@cursor_posn)
    end
    
    def move_cursor(move_vector)
      max_move = [@board.num_rows, @board.num_columns]
      move_vector.each_with_index do |move, idx|
        @cursor_posn[idx] = (@cursor_posn[idx] + move) % max_move[idx]
      end 
    end

    def swap_letter(letter)
      trade_letter = @rack.remove(letter)
      @rack.add(@letter_bank.draw)
      @letter_bank.deposit(trade_letter)
    end

    def refill_rack
      while !(@rack.full?) && !(@letter_bank.empty?) do
        @rack.add(@letter_bank.draw)
      end
    end
  end
end
