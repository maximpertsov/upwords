require 'test_helper'

class MovesTest < Minitest::Test
  include Upwords

  # class LetterBankMoveTest < PlayerTest
  #   def setup
  #     @p1 = Player.new("P1", [0,0], 7)
  #     @p2 = Player.new("P2", [0,0], 4)
  #     @bank = LetterBank.new(('A'..'Z').to_a)
  #   end

  #   def test_can_refill_rack_to_capacity
  #     @p1.refill_rack(@bank)
  #     @p2.refill_rack(@bank)

  #     assert_equal '* * * * * * *', @p1.show_hidden_rack
  #     assert_equal '* * * *', @p2.show_hidden_rack
  #   end

  #   def test_cannot_refill_rack_beyond_bank_capacity
  #     @p1.refill_rack(LetterBank.new(['A']))                 
  #     assert_equal 'A', @p1.show_rack
  #   end

  #   def test_can_swap_letter
  #     @p1.take_letter('x')
  #     @p1.swap_letter('x', @bank)

  #     assert_includes('A'..'Z', @p1.show_rack)
  #     refute_equal 'x', @p1.show_rack
  #   end

  #   def test_cannot_swap_letter_with_empty_bank
  #     @p1.take_letter('x')
  
  #     assert_raises(IllegalMove) do
  #       @p1.swap_letter('x', LetterBank.new())
  #     end
  
  #     assert_equal 'x', @p1.show_rack
  #   end
  # end
end
