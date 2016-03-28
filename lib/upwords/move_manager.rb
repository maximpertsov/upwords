module Upwords
  class MoveManager
    
    def initialize(board, dictionary) 
      @board = board
      @dict = dictionary
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
        player.take_from(@board, *@pending_move.pop[0]) # TODO: make Tile class
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
        @move_history << Shape.new(@pending_move.map {|m| m[0]})
        @pending_move.clear
      end
    end

    def pending_words
      (@board.word_positions).select do |posns|
        posns.any? {|posn| @pending_move.map {|m| m[0]}.include?(posn)}
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
      new_move = Shape.new(@pending_move.map {|m| m[0]})
      pending_move = Move.new(@pending_move.map)

      # HACK: lift pending move letters
      @board.undo_move(pending_move)

      begin
        new_move.legal?(@board, raise_exception = true)
      rescue IllegalMove => exn
        # HACK: DRY, jk...
        @board.play_move(pending_move)
        raise IllegalMove, exn.message
      end          
      
      # HACK: DRY, jk...
      @board.play_move(pending_move)

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

  end
end
