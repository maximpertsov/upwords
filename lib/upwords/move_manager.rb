module Upwords
  class MoveManager
    
    def initialize(board, dictionary)
      @board = board
      @dict = dictionary
      @pending_move = []
      update_moves
    end

    # --------------------------------
    # Player-Board Interaction Methods
    # --------------------------------
    def add(player, letter, row, col)
      selected_letter = player.play_letter(letter)
      begin
        if @pending_move.include?([row, col])
          raise IllegalMove, "You can't stack on a space more than once in a single turn!"
        elsif selected_letter == @board.top_letter(row, col)
          raise IllegalMove, "You can't stack a letter on the same letter!"
        else
          @board.play_letter(selected_letter, row, col)
          @pending_move << [row, col]
        end
      rescue IllegalMove => exn
        player.take_letter(selected_letter)
        raise IllegalMove, exn.message
      end
    end

    def undo_last(player)
      if @pending_move.empty?
        raise IllegalMove, "No moves to undo!"
      else
        letter = @board.remove_top_letter(*@pending_move.pop)
        player.take_letter(letter)
      end
    end

    def undo_all(player)
      until @pending_move.empty? do
        undo_last(player)
      end
    end

    def submit(player)
      if @pending_move.empty?
        raise IllegalMove, "You haven't played any letters!"
      elsif legal?
        player.score += pending_score
        @pending_move.clear
        update_moves
      end
    end
 
    def update_moves
      @played_moves = MoveShape.build(@board.nonempty_spaces)
    end

    def pending_words
      (@board.word_positions).select do |posns|
        posns.any? {|posn| @pending_move.include?(posn)}
      end.map do |posns|
        Word.new(posns, @board, @dict)
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
      pending_move_shape = MoveShape.build(@pending_move)
      
      if !(pending_move_shape.straight_line?)
        raise IllegalMove, "The letters in your move must be along a single row or column!"
      elsif !(pending_move_shape.gaps_covered_by?(@played_moves))
        raise IllegalMove, "The letters in your move must be internally connected!"
      elsif !letter_in_middle_square?
        raise IllegalMove, "You must play at least one letter in the middle 2x2 square!"
      elsif (@board.word_positions).empty?  
        raise IllegalMove, "Valid words must be at least two letters long!"
      elsif !(@played_moves.empty? || pending_move_shape.touching?(@played_moves))
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

    def letter_in_middle_square?
      @board.middle_square.map{|row, col| @board.stack_height(row, col) > 0}.any?
    end
    
  end
end
