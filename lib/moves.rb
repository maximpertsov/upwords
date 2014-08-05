module Upwords
  class Moves # How to make this a subclass of arrays?

    def initialize(board)
      @board = board
      @pending_moves = Array.new
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

    def get_word
      word = ""
      sorted_moves = @pending_moves.sort
      sorted_moves.each do |move|
        word << @board.top_letter(move[0], move[1])
      end
      word
    end

    def legal?

      # Are letters along only one axis?
      if !(horizontal? || vertical?)
        raise IllegalMove "Letters must be along same row or same column!"
      # Are all letters connected?
      elsif !connected?
        raise IllegalMove, "Letters must be connected!"

        # TODO: Add the following legal move condition checks:
        
        # Is at least one letter is in the middle 4 x 4 section of the board?

        # Is at least one letter orthogonally touching a letter that is already on the board?

        
      end
      
      # 4. Move is not a simple pluralization (e.g. Cat -> Cats is NOT a legal move)

      # 5. Move does not entirely cover up a word that is already on the board (i.e. you can change part of a previously-played
      #    word, but the whole thing. E.g. Cats -> Cots is legal, but Cats -> Spam is not)

      # 6. Move is a standard English word (no slang and no abbreviations) (HINT: No need to check for words longer than 10
      #    characters long)
    end
    
    # =========================================
    # Individual legal move conditions
    # =========================================

    private

    # check if all moves in array are connected and if so, result the moves in sorted order
    def connected?
      check_result = true
      sorted_moves = @pending_moves.sort
      for idx in 1...sorted_moved.size
        unless orthogonal?(sorted_moves[idx-1], sorted_moves[idx])
          check_result = false
          break
        end
      end
      check_result
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
      check_result = true
      @pending_moves.each do |move|
        unless @pending_moves[move][dim] == @pending_moves[0][dim]
          check_result = false
          break
        end 
      end
      check_result
    end

    def letter_in_middle_square?
      in_mid_square = false
      stack_height = @board.stack_height
      @board.middle_square.each do |posn|
        if stack_height(posn[0], posn[1]) > 0
          in_mid_square = true
          break
        end
      end
      in_mid_square
    end

  end
end
