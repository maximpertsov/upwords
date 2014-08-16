module Upwords
  class Moves # How to make this a subclass of arrays?

    def initialize(board)
      @board = board
      @pending_moves = Array.new
      @played_moves = @board.nonempty_spaces
      @pending_new_words = Array.new
      @pending_old_words = Array.new
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
      @played_moves = @board.nonempty_spaces
    end

    def submit
      @board.add_words
    end

    def get_word
      sorted_moves = @pending_moves.sort
      sorted_moves.map {|move| @board.top_letter(move[0], move[1])}.join
    end

    def make_word
      
    end

    def legal_structure?
    
    end

    def legal?
      puts "rows:", spanned_rows, "cols:", spanned_columns, "unrows:", skipped_rows, "uncols:", skipped_columns
      # Are letters along only one axis?
      if !straight_line? #!(horizontal? || vertical?)
        raise IllegalMove, "Letters must be along same row or same column!"
      # Are letters on board connected to each other?  
      elsif !connected_move?
        raise IllegalMove, "Letters must be connected!"
      # Is at least one letter is in the middle 4 x 4 section of the board?
      elsif !letter_in_middle_square?
        raise IllegalMove, "For the first move, you must play at least one letter in the middle 4x4 square!"
      # Is at least one letter intersection or orthogonally touching a letter that was previously played? 
      elsif !connected_to_played?
        raise IllegalMove, "At least one letter must be touching a previously played letter!"
        
      # TODO: The below condition flags moves that are connected to the pieces on the board
      # but are not connect themselves. These moves are valid, so this check below is not correct."

      # Are all letters connected? 
      # elsif !connected?
      #   raise IllegalMove, "Letters must be connected!"  
        
      



        # Move is not a simple pluralization? (e.g. Cat -> Cats is NOT a legal move)

        # Move does not entirely cover up a word that is already on the board (i.e. you can change part of a previously-played
        # word, but the whole thing. E.g. Cats -> Cots is legal, but Cats -> Spam is not)

        # Move is a standard English word (no slang and no abbreviations) (HINT: No need to check for words longer than 10
        # characters long)
        
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

    def straight_line?
      [0,1].map{|dim| spanned(dim).size == 1}.any?
    end

    def horizontal? 
      spanned_rows.size == 1
    end
    
    def vertical?
      spanned_columns.size == 1
    end

    # TODO: Add conditions to check if breaks are filled by previously played letters
    def connected_move?
      [0,1].map{|dim| skipped(dim).empty?}.all?
    end

    def letter_in_middle_square?
      @board.middle_square.map{|row, col| @board.stack_height(row, col) > 0}.any?
    end

    def orthogonal_spaces
      @pending_moves.flat_map{|row,col| [[row+1, col],[row-1, col],[row, col+1],[row, col-1]]} - @pending_moves
    end

    # FIXME: Not working correctly
    def connected_to_played?
      @played_moves.empty? || @played_moves.size > (@played_moves - orthogonal_spaces).size
    end

  end
end
