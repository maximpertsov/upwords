module Upwords
  class MoveManager
    
    def initialize(board, dictionary)
      @board = board
      @dict = dictionary
      @pending_move = []

      # Add filled board spaces as first move if board is not empty
      bs = @board.nonempty_spaces
      @move_history = bs.empty? ? [] : [MoveShape.build(bs)]
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
        player.score += 20 if player.rack_capacity == @pending_move.size
        @move_history << MoveShape.build(@pending_move)
        @pending_move.clear
      end
    end

    # TODO: Fix the ugliness
    def covered_words
      # HACK: Lift pending letter tiles off of board before entering subroutine
      lift_pending_letters = @pending_move.map do |r,c|
        [@board.remove_top_letter(r,c), r, c]
      end
      
      pending_posns = Set.new(@pending_move)

      # TODO: Make word_positions return a SortedSet
      covered = (@board.word_positions).select do |posns|
        pending_posns >= Set.new(posns)
      end.map do |posns|
        # TODO: Build words using Word object methods
        # posns.map do |r,c|
        #   @board.get_letter(r,c, pending_posns.include?([r,c]) ? 2 : 1)
        # end.join('')
        Word.new(posns, @board, @dict)
      end

      # HACK: Return pending letter tiles back to board
      lift_pending_letters.each{|l,r,c| @board.play_letter(l,r,c)}

      covered
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
    
    def pending_score
      pending_words.map{|word| word.score}.inject(:+).to_i
    end

    def legal?
      new_move = MoveShape.build(@pending_move)
      past_moves = @move_history.reverse.reduce(MoveShape.new) do |ms, m|
        m.union(ms)
      end

      # Only perform these checks if first move of game
      if @move_history.empty?
        if !letter_in_middle_square?
          raise IllegalMove, "You must play at least one letter in the middle 2x2 square!"
        elsif (@move_history.empty? && @pending_move.size < 2)
          raise IllegalMove, "Valid words must be at least two letters long!"
        end
      end
      
      # The follow checks should always be performed
      if !(new_move.straight_line?)
        raise IllegalMove, "The letters in your move must be along a single row or column!"

      # TODO: Can the next two checks be dependent on the board?
      elsif !(new_move.gaps_covered_by?(past_moves))
        raise IllegalMove, "The letters in your move must be internally connected!"

      elsif !(past_moves.empty? || new_move.touching?(past_moves))
        raise IllegalMove, "At least one letter in your move must be touching a previously played word!"

      elsif !(covered_words.empty?)
        raise IllegalMove, "Cannot completely cover up any previously-played words!"
        
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
      true
    end

    def highest_value_move(player)
      letters = player.letters
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
