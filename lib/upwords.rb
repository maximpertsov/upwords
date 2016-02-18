require 'upwords/version'
require 'upwords/board'
require 'upwords/move_unit'
require 'upwords/letter_bank'
require 'upwords/letter_rack'
require 'upwords/dictionary' # finish implementing
require 'upwords/moves'
require 'upwords/word'
require 'upwords/player'
require 'upwords/graphics'
require 'upwords/game'

module Upwords
  # Raised when player makes an illegal move
  class IllegalMove < StandardError
  end
end
