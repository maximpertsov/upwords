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

    def legal?
      legal = true
      
      # Checks if pending move meets the following conditions:
      while legal do
      
        # No stacking on top of pending letters!
        legal = no_stacks?

        # 2. All are letters along only one axis
        legal = (vertical? || horizontal?)

        # 1. All letters are connected (Be careful that no words wrap around edges of board...)
        legal = connected?

      

      

      # 3a. IF NO LETTERS ARE ON THE BOARD YET: At least one letter is in the middle 4 x 4 section of the board
      # 3b. IF LETTERS ARE ON THE BOARD: At least one letter is orthogonally touching a letter that is already on the board
      
      # 4. Move is not a simple pluralization (e.g. Cat -> Cats is NOT a legal move)

      # 5. Move does not entirely cover up a word that is already on the board (i.e. you can change part of a previously-played
      #    word, but the whole thing. E.g. Cats -> Cots is legal, but Cats -> Spam is not)

      # 6. Move is a standard English word (no slang and no abbreviations) (HINT: No need to check for words longer than 10
      #    characters long)

      end
    end
    
    # =========================================
    # Individual legal move conditions
    # =========================================

    private

    # NOTE: Array.sort method seems order positions from top-left to bottom-right]

    def no_stacks?
      @pending_moves.size == @pending_moves.uniq.size
    end

    # check if all moves in array are connected and if so, result the moves in sorted order
    def connected?
      sorted_moves = @pending_moves.sort
      result = Array.new(sorted_moves[0])
      for idx in 1...sorted_moved.size
        if !orthogonal?(sorted_moves[idx-1], sorted_moves[idx])
          result = false
          break
        else
          result << sorted_moves[idx]
        end
      end
      result
    end

    def orthogonal?(posn1, posn2)
      ((posn1[0] == posn2[0] && (posn1[1] - posn2[1]).abs <= 1) || 
       (posn1[1] == posn2[1] && (posn1[0] - posn2[0]).abs <= 1))
    end

    def horizontal? 
      along_one_dimension?(0) 
    end
    
    def vertical?
      along_one_dimension?(1)
    end
    
    def along_one_dimension?(dim)
      result = true
      @pending_moves.each do |move| 
        if @pending_moves[move][dim] != @pending_moves[0][dim]
          result = false
          break
        end
      end
      result
    end

  end
end
