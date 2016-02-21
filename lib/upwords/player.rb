module Upwords
  class Player

    attr_reader :name, :cursor_posn
    attr_accessor :score

    def initialize(name, init_cursor_posn, rack_capacity=7)
      @name = name
      @cursor_posn = init_cursor_posn
      @rack = LetterRack.new(rack_capacity)
      @score = 0
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

    def rack_capacity
      @rack.capacity
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
