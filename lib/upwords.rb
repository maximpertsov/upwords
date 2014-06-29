require_relative 'board'
require_relative 'letter_bank'
require_relative 'letter_rack'
require_relative 'player'
require_relative 'game'

module Upwords
  # Raised when player makes an illegal move
  class IllegalMove < StandardError
  end
end





