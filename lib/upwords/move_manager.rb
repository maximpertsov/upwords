module Upwords
  class MoveManager
    
    def initialize(board, dictionary, letter_bank)
      @board = board
      @dict = dictionary
      @letter_bank = letter_bank
      @pending_moves = []
      @played_moves = @board.nonempty_spaces
      @played_words = Hash.new {|h,k| h[k] = 0} # Counter Hash
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
    def add(player, letter, row, col)
      selected_letter = player.play_letter(letter)
      begin
        if self.include?([row, col])
          raise IllegalMove, "You can't stack on a space more than once in a single turn!"
        elsif selected_letter == @board.top_letter(row, col)
          raise IllegalMove, "You can't stack a letter on the same letter!"
        else
          @board.play_letter(selected_letter, row, col)
          @pending_moves << MoveUnit.new(selected_letter, row, col) 
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
      end
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
      new_letter = @letter_bank.draw # Will raise error if bank is empty
      begin
        trade_letter = player.play_letter(letter)  #.letter
        player.take_letter(new_letter)
        @letter_bank.deposit(trade_letter)
      rescue IllegalMove => exn
        @letter_bank.deposit(new_letter)
        raise IllegalMove, exn.message
      end
    end

    def clear
      @pending_moves.clear
    end

    def update_moves
      update_played_moves
      update_played_words
    end

    def update_played_moves
      @played_moves = (@board.nonempty_spaces).map do |r,c|
        MoveUnit.new(@board.top_letter(r, c), r, c)
      end.to_set
    end
    
    def update_played_words
      @played_words = words_to_counter(positions_to_words(@board.word_positions))
    end

    def pending_words
      new_words = positions_to_words(@board.word_positions)
      counter = words_to_counter(new_words)

      new_words.select do |word|
        counter[word.to_s] - @played_words[word.to_s] > 0
      end 
    end

    def pending_illegal_words
      pending_words.reject {|word| word.legal?}
    end
    
    def pending_result
      output = (pending_words.map{|word| "#{word} (#{word.score})"}.join ", ") 
      output + " | Total: #{pending_score}" if output.size > 0
    end

    def pending_score
      pending_words.map{|word| word.score}.inject(:+).to_i
    end

    def legal?
      if !straight_line?
        raise IllegalMove, "The letters in your move must be along a single row or column!"
      elsif !connected_move?
        raise IllegalMove, "The letters in your move must be internally connected!"
      elsif !letter_in_middle_square?
        raise IllegalMove, "You must play at least one letter in the middle 2x2 square!"
      elsif (@board.word_positions).empty?  
        raise IllegalMove, "Valid words must be at least two letters long!"
      elsif !connected_to_played?
        raise IllegalMove, "At least one letter in your move must be touching a previously played word!"
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
      # - Move is not a simple pluralization? (e.g. Cat -> Cats is NOT a legal move)
      # - Move does not entirely cover up a word that is already on the board (i.e. you can change part of a previously-played
      #   word, but the whole thing. E.g. Cats -> Cots is legal, but Cats -> Spam is not)
      true
    end
    
    # =========================================
    # Individual legal move conditions
    # =========================================
    
    def straight_line?
      MoveUnit.straight_line?(@pending_moves)
    end

    def connected_move?     
      gaps = MoveUnit.gaps(@pending_moves)
      gaps.empty? || (gaps - (@played_moves.map {|mu| mu.posn})).empty? 
    end

    def letter_in_middle_square?
      @board.middle_square.map{|row, col| @board.stack_height(row, col) > 0}.any?
    end

    def connected_to_played?
      @played_moves.empty? || MoveUnit.touching?(@pending_moves, @played_moves)
    end

    private

    # convert word position set to Word array
    def positions_to_words(word_posns)
      word_posns.map do |posns|
        new_word = Word.new(posns, @board, @dict)
      end
    end

    # convert Word array to word counter
    def words_to_counter(words)
      counter = Hash.new {|h,k| h[k] = 0}

      words.each do |word|
        counter[word.to_s] += 1
      end

      counter
    end
    
  end
end
