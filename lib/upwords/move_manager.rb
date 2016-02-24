module Upwords
  class MoveManager
    attr_reader :cursor
    
    def initialize(board, dictionary, letter_bank,
                   init_cursor_posn = [0,0])
      @board = board
      @dictionary = dictionary
      @letter_bank = letter_bank
      @pending_moves = []
      @played_moves = @board.nonempty_spaces
      @played_words = Hash.new {|h,k| h[k] = 0} # Counter Hash
      @cursor = init_cursor_posn
      update_moves
    end

    def empty?
      @pending_moves.empty?
    end

    def include? posn
      @pending_moves.map{|mu| mu.posn}.include? posn
    end

    # --------------------------------
    # Player-Board Interaction Methods
    # --------------------------------
    def add(player, letter)
      
      selected_letter = player.play_letter(letter)
      posn = @cursor.dup
      begin
        if @pending_moves.include?(posn)
          raise IllegalMove, "You can't stack on a space more than once in a single turn!"
        else
          @board.play_letter(selected_letter, *posn)
          @pending_moves << MoveUnit.new(selected_letter, *posn) 
        end
      rescue IllegalMove => exn
        player.take_letter(selected_letter)
        raise IllegalMove, exn.message
      end
    end

    def undo_last(player)
      if empty?
        raise IllegalMove, "No moves to undo!"
      else
        letter = @board.remove_top_letter(*@pending_moves.pop.posn)
        player.take_letter(letter)
      end
    end

    def undo_all(player)
      until empty? do
        undo_last(player)
      end
    end

    def submit(player)
      if empty?
        raise IllegalMove, "You haven't played any letters!"
      else legal?
        player.score += pending_score
        clear
        refill_rack(player) # TODO: Refactor
        update_moves
        # @board.finalize! # Not implemented
      end
    end

    def move_cursor(rows, cols)
      @cursor[0] = (@cursor[0] + rows) % @board.num_rows
      @cursor[1] = (@cursor[1] + cols) % @board.num_columns 
    end
    
    # --------------------------------------
    # Player-Letter Bank Interaction Methods # TODO: REFACTOR
    # --------------------------------------
    def refill_rack(player)
      until (player.rack_full?) || (@letter_bank.empty?) do
        player.take_letter(@letter_bank.draw)
      end
    end

    def swap_letter(player, letter)
      new_letter = @letter_bank.draw # Will raise error if bank if empty
      begin
        trade_letter = player.play_letter(letter).letter
        player.take_letter(new_letter)
        @letter_bank.deposit(trade_letter)
      rescue IllegalMove => exn
        @letter_bank.deposit(new_letter)
        raise IllegalMove, exn.message
      end
    end

    # --------------------------------------
    # Move shape
    # --------------------------------------
    # def straight_line?
    #   MoveUnit.straight_line?(@pending_moves)
    # end

    # def no_gaps?
    #   MoveUnit.skipped_rows(@pending_moves)
    # end
    
    # --------------------------------------
    def clear
      @pending_moves.clear
    end

    def update_moves
      update_played_moves
      update_played_words
    end

    def update_played_moves
      @played_moves = @board.nonempty_spaces
    end
    
    def update_played_words
      @played_words.clear
      (@board.words).each do |word|
        @played_words[word.to_str] += 1
      end
    end

    def pending_words
      new_words = Hash.new {|h,k| h[k] = 0}
      (@board.words).each do |word|
        new_words[word.to_str] += 1
      end
      
      (@board.words).select {|word| new_words[word.to_str] - @played_words[word.to_str] > 0}
    end

    def pending_illegal_words
      pending_words.reject{|word| @dictionary.legal_word? word.to_s.upcase}
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
        raise IllegalMove, "You must play at least one letter in the middle 2x2 square!"
      # (First move only) Is there at least one word that is two letters or more on the board?
      elsif (@board.words).empty?  
        raise IllegalMove, "Valid words must be at least two letters long!"
      # Is at least one letter intersecting or orthogonally touching a previously played letter? 
      elsif !connected_to_played?
        raise IllegalMove, "At least one letter in your move must be touching a previously played word!"
      # Are all resulting words in Official Scrabble Players Dictionary
      elsif !pending_illegal_words.empty?
        error_msg = pending_illegal_words.join(", ")
        case pending_illegal_words.size
        when 1
          error_msg += " is not a legal word!"
        else
          error_msg += " are not legal words!"
        end
        raise IllegalMove, error_msg
      end
      # TODO: Add the following legal move checks:
      # - Cannot stack a letter on top of the same letter
      # - Move is not a simple pluralization? (e.g. Cat -> Cats is NOT a legal move)
      # - Move does not entirely cover up a word that is already on the board (i.e. you can change part of a previously-played
      #   word, but the whole thing. E.g. Cats -> Cots is legal, but Cats -> Spam is not)
      true
    end
    
    # =========================================
    # Individual legal move conditions
    # =========================================

    # private

    # What positions in a given dimension are spanned by the pending moves
    def spanned(dim)
      #@pending_moves.map{|posn| posn[dim]}.uniq
      @pending_moves.map{|mu| mu.posn[dim]}.uniq
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
      # @pending_moves.flat_map{|row, col| [[row+1, col],[row-1, col],[row, col+1],[row, col-1]]} - @pending_moves
      @pending_moves.flat_map{|mu| mu.orthogonal_spaces} 
    end

    def connected_to_played?
    #   @played_moves.empty? || @played_moves.size > (@played_moves - (orthogonal_spaces + @pending_moves)).size 
      @played_moves.empty? || @played_moves.size > (@played_moves - orthogonal_spaces).size 
    end

  end
end
