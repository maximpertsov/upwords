class LetterRack

  attr_reader :rack

  def initialize(letter_bank)
    @bank = letter_bank
    @rack = Array.new(capacity)
    refill
  end
  
  # maximum number of letters that fit in each player's rack
  def capacity
    7
  end

  def has_letter?(letter)
    @rack.include? letter
  end

  # re-fill letter rack to capacity (until letter bank is empty)
  def refill
    # draw a random letter from bank for each empty space in rack
    (@rack.compact.size...capacity).each do |i|
      if !@bank.empty?
        @rack[i] = @bank.draw
      # stop drawing if letter bank is empty
      else
        break
      end
    end
  end

  # swap letter in rack for a random letter from the bank
  def swap(letter)
    if !has_letter?(letter)
      raise IllegalMove, "You don't have this letter"
    else
      @bank.deposit(letter)
      @rack[@rack.index{letter}] = @bank.draw
    end
  end
end
