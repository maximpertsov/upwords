module Upwords
  class Player

    attr_reader :name
    attr_accessor :score, :skip_count

    def initialize(name, rack_capacity=7)
      @name = name
      @rack = LetterRack.new(rack_capacity)
      @score = 0
      @skip_count = 0
    end

    def letters
      @rack.letters.dup
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

    def rack_empty?
      @rack.empty?
    end

    def rack_capacity
      @rack.capacity
    end

    def take_letter(letter)
      @rack.add(letter)
    end

    def play_letter(letter)
      @rack.remove(letter)
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
