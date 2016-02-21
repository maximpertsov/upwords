module Upwords
  class Player

    attr_reader :name, :cursor_posn
    attr_accessor :score

    def initialize(name)
      @name = name
      @rack = LetterRack.new(capacity=7)
      @score = 0
      
      # HACK: 4,4 is the middle square of the board, added
      # so I can strip board class out of player
      @cursor_posn = [4,4] #@board.middle_square[0]
    end

    def show_rack
      @rack.show
    end

    def show_hidden_rack
      @rack.show_masked
    end

    def rack_full?
      @rack.full?
    end

    def take_letter(letter)
      @rack.add(letter)
    end

    def play_letter(letter)
      MoveUnit.new(@rack.remove(letter), *@cursor_posn)
    end
    
    def move_cursor(move_vector, bounds)
      move_vector.each_with_index do |move, i|
        @cursor_posn[i] = (@cursor_posn[i] + move) % bounds[i]
      end 
    end

    def swap_letter(letter, letter_bank)
      new_letter = letter_bank.draw # Will raise error if bank if empty
      trade_letter = @rack.remove(letter)
      @rack.add(new_letter)
      letter_bank.deposit(trade_letter)
    end

    def refill_rack(letter_bank)
      while !(rack_full?) && !(letter_bank.empty?) do
        take_letter(letter_bank.draw)
      end
    end
  end
end
