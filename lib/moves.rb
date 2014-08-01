module Upwords
  class Moves

    def initialize(board)
      @board = board
      @pending_moves = Array.new
    end

    def empty?
      @pending_moves.empty?
    end

    def undo_last
      undo_posn = @pending_moves.pop
      @board.remove_top_letter(undo_posn[0], undo_posn[1])
    end

    def add(posn)
      @pending_moves << Array.new(posn)
    end

    def clear
      @pending_moves.clear
    end
    
  end
end
