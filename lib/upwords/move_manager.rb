module Upwords
  class MoveManager
    def initialize(board, dictionary, *players)
      @board = board
      @dict = dictionary
      @players = players
    end

    # def pending_move?
    #   !(@pending_move.empty?)
    # end
    
    # def add_move(letter, row, col)
    #   @pending_move.extend(MoveUnit.new(letter, row, col))
    # rescue IllegalMove => exn
    #   raise 
    # end
    
    
  end
end
