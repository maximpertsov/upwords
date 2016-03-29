module Upwords
  class Move
    
    def initialize(tiles = [])
      @shape = Shape.new(tiles.map {|(row, col), letter| [row, col]})
      @move = tiles.to_h
    end

    # TODO: remove dict from word class
    # TODO: move score and new word methods to board class?
    def score(board, player)
      final_score = (board.play_move(self).word_positions).select do |word_posns|
        word_posns.any? {|row, col| position?(row, col)}
        
      end.reduce(player.rack_capacity == @move.size ? 20 : 0) do |score, word_posns|
        score += Word.new(word_posns, board).score
      end

      # HACK: Return letters
      remove_from(board)

      final_score
    end

    # TODO: Add the following legal move checks:
    # - Move is not a simple pluralization? (e.g. Cat -> Cats is NOT a legal move)
    def legal?(board, dict, raise_exception = false)
      legal_shape?(board, raise_exception) && legal_words?(board, dict, raise_exception)
    end

    def legal_shape?(board, raise_exception = false)
      @shape.legal?(board, raise_exception)
    end

    def can_play_letters?(board, raise_exception = false)
      @move.all? do |(row, col), letter|
        board.can_play_letter?(letter, row, col, raise_exception)
      end
    end

    # TODO: Add the following legal move checks:
    # - Move is not a simple pluralization? (e.g. Cat -> Cats is NOT a legal move)
    def legal_words?(board, dict, raise_exception = false)

      if can_play_letters?(board, raise_exception)    
        bad_words = self.new_illegal_words(board, dict)
        if bad_words.empty?
          return true
        else
          raise IllegalMove, "#{bad_words.join(', ')} #{bad_words.size==1 ? 'is not a legal word' : 'are not legal words'}!" if raise_exception
        end
      end

      return false
    end

    def position?(row, col)
      @move.key?([row, col])
    end

    def [](row, col)
      @move[[row, col]]
    end
    
    def play(board)
      @move.reduce(board) do |b, (posn, letter)| 
        b.play_letter(letter, *posn)
        b
      end
    end

    # TODO: consider move main subroutine to Shape class?
    def remove_from(board)
      if @move.any? {|(row, col), letter| board.top_letter(row, col) != letter}
        raise IllegalMove, "Move does not exist on board and therefore cannot be removed!"
      else
        (@move.each_key).reduce(board) do |b, posn| 
          b.remove_top_letter(*posn)
          b
        end
      end
    end

    # TODO: handle exceptions when board cannot be updated with new move
    # TODO: move score and new word methods to board class?
    def new_words(board)
      # HACK: update board with new move
      words = (board.play_move(self).word_positions).select do |word_posns|
        word_posns.any? {|row, col| position?(row, col)}
        
      end.map do |word_posns|
        word_posns.map do |row, col|
          # if position?(row, col)
          #   self[row, col]
          # else
            board.top_letter(row, col)
          # end
        end.join 
      end

      # HACK: remove move from board
      remove_from(board)

      words
    end

    def new_illegal_words(board, dict)
      new_words(board).reject {|word| dict.legal_word?(word)}
    end

  end
end
