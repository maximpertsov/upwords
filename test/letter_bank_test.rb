require 'test_helper'

class LetterBankTest < Minitest::Test
  include Upwords

  def setup
    @bank = LetterBank.new(['A','B','C','D'])
  end

  def test_can_draw_letters
    4.times do
      assert_includes(['A','B','C','D'], @bank.draw)
    end
  end

  def test_empty?
    refute @bank.empty?
    
    4.times { @bank.draw }

    assert @bank.empty?
  end

  def test_can_deposit_new_letters
    @bank.deposit('E')

    5.times do
      assert_includes(['A','B','C','D','E'], @bank.draw)
    end

    assert @bank.empty?
  end
end
