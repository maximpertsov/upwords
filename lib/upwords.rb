require 'set'

require 'upwords/version'
require 'upwords/board'

#require 'upwords/unionfind'
#require 'upwords/move'
#require 'upwords/move_manager'

require 'upwords/letter_bank'
require 'upwords/letter_rack'
require 'upwords/dictionary'

require 'upwords/move_unit'
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
