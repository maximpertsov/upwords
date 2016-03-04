require 'set'
require 'matrix'
require 'curses'

require 'upwords/version'
require 'upwords/board'

require 'upwords/letter_bank'
require 'upwords/letter_rack'
require 'upwords/dictionary'

require 'upwords/move_shape'
require 'upwords/move_manager'
require 'upwords/cursor'

require 'upwords/word'
require 'upwords/player'
require 'upwords/graphics'
require 'upwords/game'

module Upwords
  # Raised when player makes an illegal move
  class IllegalMove < StandardError
  end
end
