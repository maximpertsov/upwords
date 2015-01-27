module Upwords
  class Moves # How to make this a subclass of arrays?

    def initialize(game)
      @game = game
      @board = @game.board
      @dictionary = @game.dictionary
      @pending_moves = Array.new
      update_moves
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

    def update_moves
      update_played_moves
      update_played_words
    end

    def pending_words
      all_words = @board.words_on_rows + @board.words_on_columns
      new_words = (@board.words_on_rows + @board.words_on_columns).map{|word| word.to_str} - @played_words
      all_words.select{|word| (new_words.include? word.to_str)}
    end

    def pending_result
      output = (pending_words.map{|word| "#{word} (#{word.score})"}.join ", ") 
      output + " | Total: #{pending_score}" if output.size > 0
    end

    def pending_score
      pending_words.map{|word| word.score}.inject(:+).to_i
    end

    def legal?
      # Are letters all along one axis?
      if !straight_line?
        raise IllegalMove, "The letters in your move must be along a single row or column!"
      # Are letters on board connected to each other?  
      elsif !connected_move?
        raise IllegalMove, "The letters in your move must be connected!"
      # Is at least one letter is in the middle 4 x 4 section of the board?
      elsif !letter_in_middle_square?
        raise IllegalMove, "You must play at least one letter in the middle 4x4 square!"
      # Is at least one letter intersecting or orthogonally touching a previously played letter? 
      elsif !connected_to_played?
        raise IllegalMove, "At least one letter in your move must be touching a previously played word!"
      # Are all resulting words in Official Scrabble Players Dictionary
      elsif !(pending_words.all? {|word| @dictionary.legal_word? word.to_s.upcase})
        illegal_words = pending_words.reject{|word|}.map{|word| word.to_s}
        error_msg = illegal_words.join(", ") + " are not legal words!"
        raise IllegalMove, error_msg
      end
      # TODO: Add the following legal move checks:
      # - Move is not a simple pluralization? (e.g. Cat -> Cats is NOT a legal move)
      # - Move does not entirely cover up a word that is already on the board (i.e. you can change part of a previously-played
      #   word, but the whole thing. E.g. Cats -> Cots is legal, but Cats -> Spam is not)
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
      skipped_spaces.empty? || (skipped_spaces - @played_moves).empty? 
    end

    def letter_in_middle_square?
      @board.middle_square.map{|row, col| @board.stack_height(row, col) > 0}.any?
    end

    def orthogonal_spaces
      @pending_moves.flat_map{|row,col| [[row+1, col],[row-1, col],[row, col+1],[row, col-1]]} - @pending_moves
    end

    def connected_to_played?
      @played_moves.empty? || @played_moves.size > (@played_moves - (orthogonal_spaces + @pending_moves)).size
    end

    def update_played_moves
      @played_moves = @board.nonempty_spaces
    end
    
    def update_played_words
      @played_words = (@board.words_on_rows + @board.words_on_columns).map{|word| word.to_str}
    end

  end
end
