module Upwords
  class Moves # How to make this a subclass of arrays?

    def initialize(board)
      @board = board
      @pending_moves = Array.new
      @@played_moves = @board.nonempty_spaces
      # @pending_new_words = Array.new
      # @pending_old_words = Array.new
    end

    def empty?
      @pending_moves.empty?
    end

    def include? move
      @pending_moves.include? move
    end

    def undo_last
      undo_move = @pending_moves.pop
      @board.remove_top_letter(undo_move[0], undo_move[1])
    end

    def add(posn)
      @pending_moves << Array.new(posn)
    end

    def clear
      @pending_moves.clear
    end

    def to_played_moves
      @@played_moves = @board.nonempty_spaces
    end

    def get_word
      sorted_moves = @pending_moves.sort
      sorted_moves.map {|move| @board.top_letter(move[0], move[1])}.join
    end

    def legal?
      # Are letters all along one axis?
      if !straight_line?
        raise IllegalMove, "Letters must be along same row or same column!"
      # Are letters on board connected to each other?  
      elsif !connected_move?
        raise IllegalMove, "Letters must be connected!"
      # Is at least one letter is in the middle 4 x 4 section of the board?
      elsif !letter_in_middle_square?
        raise IllegalMove, "For the first move, you must play at least one letter in the middle 4x4 square!"
      # Is at least one letter intersecting or orthogonally touching a previously played letter? 
      elsif !connected_to_played?
        raise IllegalMove, "At least one letter must be touching a previously played letter!"        
      # TODO: Add the following legal move checks:
      # - Move is not a simple pluralization? (e.g. Cat -> Cats is NOT a legal move)
      # - Move does not entirely cover up a word that is already on the board (i.e. you can change part of a previously-played
      #   word, but the whole thing. E.g. Cats -> Cots is legal, but Cats -> Spam is not)
      # - Move is a standard English word (no slang and no abbreviations) (HINT: No need to check for words longer than 10
      #   characters long)
      end
      true
    end
    
    # =========================================
    # Individual legal move conditions
    # =========================================

    private

    # What positions in a given dimension are spanned by the pending moves
    def spanned(dim)
      @pending_moves.map{|posn| posn[dim]}.uniq
    end

    def spanned_rows
      spanned(0)
    end

    def spanned_columns
      spanned(1)
    end

    # What positions in a given dimension are skipped within the span of the pending moves
    def skipped(dim)
      lo, hi = spanned(dim).minmax
      (lo..hi).to_a - spanned(dim)
    end

    def skipped_rows
      skipped(0)
    end

    def skipped_columns
      skipped(1)
    end

    def skipped_spaces
      if horizontal?
        spanned_rows.product skipped_columns
      elsif vertical?
        skipped_rows.product spanned_columns
      end
    end
    
    def straight_line?
      horizontal? || vertical?
    end

    def horizontal? 
      spanned_rows.size == 1
    end
    
    def vertical?
      spanned_columns.size == 1
    end

    def connected_move?
      skipped_spaces.empty? || (skipped_spaces - @@played_moves).empty? 
    end

    def letter_in_middle_square?
      @board.middle_square.map{|row, col| @board.stack_height(row, col) > 0}.any?
    end

    def orthogonal_spaces
      @pending_moves.flat_map{|row,col| [[row+1, col],[row-1, col],[row, col+1],[row, col-1]]} - @pending_moves
    end

    def connected_to_played?
      @@played_moves.empty? || @@played_moves.size > (@@played_moves - (orthogonal_spaces + @pending_moves)).size
    end

  end
end
