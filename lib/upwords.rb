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

  # Letters available in 10 x 10 version of Upwords
  ALL_LETTERS = {
    8 => ["E"],
    7 => ["A", "I", "O"],
    6 => ["S"],
    5 => ["D", "L", "M", "N", "R", "T", "U"],
    4 => ["C"],
    3 => ["B", "F", "G", "H", "P"],
    2 => ["K", "W", "Y"],
    1 => ["J", "Qu", "V", "X", "Z"]
  }.flat_map {|count, letters| letters * count}

  # Curses Key Constants
  ESCAPE = 27
  SPACE = ' '
  DELETE = 127
  ENTER = 10

  # Official Scrabble Player Dictionary file
  OSPD_FILE = "data/ospd.txt"
  
end
