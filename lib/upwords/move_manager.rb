module Upwords
  class MoveManager
    
    def initialize(board, dictionary, min_word_size = 2)
      @board = board
      @dict = dictionary
      @min_word_size = min_word_size
      @pending_move = []

      # Add filled board spaces as first move if board is not empty
      bs = @board.nonempty_spaces
      @move_history = bs.empty? ? [] : [Shape.new(bs)]
    end

    # --------------------------------
    # Player-Board Interaction Methods
    # --------------------------------
    def add(player, letter, row, col)
      if @pending_move.include?([row, col])
        raise IllegalMove, "You can't stack on a space more than once in a single turn!"
      else
        @pending_move << player.play_letter(@board, letter, row, col)
      end
    end

    def undo_last(player)
      if @pending_move.empty?
        raise IllegalMove, "No moves to undo!"
      else
        player.take_from(@board, *@pending_move.pop)
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
        player.score += pending_score(player)
        @move_history << Shape.new(@pending_move.map { |row, col| [row, col, @board.top_letter(row, col)] })
        @pending_move.clear
      end
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
    
    def pending_score(player)
      pending_words.map{|word| word.score}.inject(:+).to_i + (player.rack_capacity == @pending_move.size ? 20 : 0)
    end

    def legal?
      new_move = Shape.new(@pending_move)
      
      # HACK: lift pending move letters
      pending_move = @pending_move.map {|row, col| [[row, col], @board.remove_top_letter(row, col)]}.to_h

      begin
        # Only perform these checks if first move of game
        if @board.empty?
          if !letter_in_middle_square?
            raise IllegalMove, "You must play at least one letter in the middle 2x2 square!"
          elsif new_move.size < @board.min_word_length
            raise IllegalMove, "Valid words must be at least #{@board.min_word_length} letter(s) long!"
          end
        end
        
        # The follow checks should always be performed
        if !(new_move.straight_line?)
          raise IllegalMove, "The letters in your move must be along a single row or column!"

        elsif !(new_move.gaps_covered_by?(@board))
          raise IllegalMove, "The letters in your move must be internally connected!"

        elsif !(@board.empty? || new_move.touching?(@board))
          raise IllegalMove, "At least one letter in your move must be touching a previously played word!"

        elsif new_move.covering_moves?(@board)  
          raise IllegalMove, "Cannot completely cover up any previously-played words!"
        end

      rescue IllegalMove => exn
        # HACK: DRY, jk...
        pending_move.each {|(row, col), letter| @board.play_letter(letter, row, col)}
        raise IllegalMove, exn.message
      end          
      
      # HACK: DRY, jk...
      pending_move.each {|(row, col), letter| @board.play_letter(letter, row, col)}
      
      # Word checks start here
      
      if !pending_illegal_words.empty?
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
      return true
    end

    # =========================================
    # Individual legal move conditions
    # =========================================

    private
    
    def letter_in_middle_square?
      @board.middle_square.any? do |posn|
        @pending_move.include?(posn)
      end
    end
    
  end
end
