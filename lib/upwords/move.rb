module Upwords
  class Move
    
    def initialize(tiles = [])
      @shape = Shape.new(tiles.map {|(row, col), letter| [row, col]})
      @move = tiles.to_h
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
    def new_words(board)
      # HACK: update board with new move
      words = (play(board).word_positions).select do |word_posns|
        word_posns.any? {|row, col| position?(row, col)}
        
      end.map do |word_posns|
        word_posns.map do |row, col|
          if position?(row, col)
            self[row, col]
          else
            board.top_letter(row, col)
          end
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
