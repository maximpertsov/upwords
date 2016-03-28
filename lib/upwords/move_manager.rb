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

    # TODO: move this logic somewhere else
    def pending_words
      (@board.word_positions).select do |posns|
        posns.any? {|posn| @pending_move.map {|m| m[0]}.include?(posn)}
      end.map do |posns|
        Word.new(posns, @board)
      end
    end
    
    def pending_score(player)
      Move.new(@pending_move).score(@board, player)
    end

    def legal?
      pending_move = Move.new(@pending_move)

      # HACK: lift pending move letters
      @board.undo_move(pending_move)

      begin
        pending_move.legal?(@board, @dict, raise_exception = true)
      rescue IllegalMove => exn
        # HACK: DRY, jk...
        @board.play_move(pending_move)
        raise IllegalMove, exn.message
      end          
      
      # HACK: DRY, jk...
      @board.play_move(pending_move)
      
      return true
    end

  end
end
