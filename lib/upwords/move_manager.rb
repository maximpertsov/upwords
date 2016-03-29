module Upwords
  class MoveManager
    
    def initialize(board, dictionary) 
      @board = board
      @dict = dictionary
      @pending_move = []
      @move_history = [] # TODO: Add filled board spaces as first move if board is not empty
    end

    # --------------------------------
    # Player-Board Interaction Methods
    # --------------------------------
    def add(player, letter, row, col)
      # TODO: remove the need for @pending_move.map
      if (@pending_move.map {|m| m[0]}).include?([row, col])
        raise IllegalMove, "You can't stack on a space more than once in a single turn!"
      elsif
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
        @move_history << Move.new(@pending_move)
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
      prev_board = Board.build(@move_history, @board.size, @board.max_height)
      Move.new(@pending_move).score(prev_board, player)
    end

    def legal?
      prev_board = Board.build(@move_history, @board.size, @board.max_height)
      Move.new(@pending_move).legal?(prev_board, @dict, raise_exception = true)
    end

  end
end
