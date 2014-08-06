module Upwords
  class Moves # How to make this a subclass of arrays?

    def initialize(board)
      @board = board
      @pending_moves = Array.new
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

    def submit
      @board.add_words
    end

    def get_word
      word = ""
      sorted_moves = @pending_moves.sort
      sorted_moves.each do |move|
        word << @board.top_letter(move[0], move[1])
      end
      word
    end

    def make_word
      
    end

    def legal_structure?
    
    end

    def legal?
      # Are letters along only one axis?
      if !(horizontal? || vertical?)
        raise IllegalMove, "Letters must be along same row or same column!"
        
      # TODO: The below condition flags moves that are connected to the pieces on the board
      # but are not connect themselves. These moves are valid, so this check below is not correct."
      # Are all letters connected? 
      # elsif !connected?
      #   raise IllegalMove, "Letters must be connected!"
        
      # Is at least one letter is in the middle 4 x 4 section of the board?
      elsif !letter_in_middle_square?
        raise IllegalMove, "For the first move, you must play at least one letter in the middle 4x4 square!"
      # Is at least one letter orthogonally touching a letter that is already on the board?
      elsif !connected_to_existing?
        raise IllegalMove, "At least one letter must be touching a previously played letter!"

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

    # FIXME: see comment in legal? method
    # check if all moves in array are connected and if so, result the moves in sorted order
    # def connected?
    #   check_result = true
    #   sorted_moves = @pending_moves.sort
    #   for idx in 1...sorted_moves.size
    #     unless orthogonally_connected?(sorted_moves[idx-1], sorted_moves[idx])
    #       check_result = false
    #       break
    #     end
    #   end
    #   check_result
    # end

    # def orthogonally_connected?(posn1, posn2)
    #   ((posn1[0] == posn2[0] && (posn1[1] - posn2[1]).abs <= 1) || 
    #    (posn1[1] == posn2[1] && (posn1[0] - posn2[0]).abs <= 1))
    # end

    def orthogonal_spaces
      orthogonal_spaces = []
      @pending_moves.each do |posn|
        orthogonal_spaces += [-1,1].map{|i| [i + posn[0], posn[1]]} + [-1,1].map{|j| [posn[0], j + posn[1]]}
      end
      orthogonal_spaces.uniq
    end

    def horizontal? 
      along_one_dimension?(0) 
    end
    
    def vertical?
      along_one_dimension?(1)
    end
    
    def along_one_dimension?(dim)
      @pending_moves.map{|move| @pending_moves[0][dim] == move[dim]}.all?
    end

    def letter_in_middle_square?
      @board.middle_square.map{|posn| @board.stack_height(posn[0], posn[1]) > 0}.any?
    end

    # def connected?
    #   nonempty_posns = @board.nonempty_positions
    #   if horizontal?
    #     row = @pending_moves[0][0]
    #     range = @pending_moves.map{|row,col| }
    #     (range[0]..range[1]).map{|
    #     @board.nonempty_positions 
    #   else
    #     range = @pending_moves.map{|row,col| row}
    #   end
        
    # end

    def connected_to_existing?
      nonempty_posns = @board.nonempty_positions - @pending_moves
      nonempty_posns.empty? || nonempty_posns.size > (nonempty_posns - orthogonal_spaces).size
    end

=begin Graveyard

    def along_one_dimension?(dim)
      check_result = true
      @pending_moves.each_index do |idx|
        unless @pending_moves[idx][dim] == @pending_moves[0][dim]
          check_result = false
          break
        end 
      end
      check_result
    end

    def letter_in_middle_square?
      in_mid_square = false
      @board.middle_square.each do |posn|
        if @board.stack_height(posn[0], posn[1]) > 0
          in_mid_square = true
          break
        end
      end
      in_mid_square
    end

    def connected_to_existing?
      check_result = false
      nonempty_posns = @board.nonempty_positions - @pending_moves
      if nonempty_posns.empty?
        check_result = true
      else
        @pending_moves.each do |move|
          nonempty_posns.each do |npos|
            if orthogonally_connected?(move, npos)
              check_result = true
              break
            end
          end
          if check_result
            break
          end
        end
      end
      check_result
    end

=end

  end
end
