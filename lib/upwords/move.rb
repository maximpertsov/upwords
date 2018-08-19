# frozen_string_literal: true

# Encapsulates a possible move that a player could submit in a single turn

module Upwords
  class Move
    # Initialized with a list of 2D arrays, each containing a position (row, col) and a letter
    def initialize(tiles = [])
      @shape = Shape.new(tiles.map { |(row, col), _letter| [row, col] })
      @move = tiles.to_h
    end

    # Calculate value of move
    # Most of the word score calculate logic is in the Word class. However, this method
    # will also add 20 points if the player uses all of their letters in the move
    def score(board, player)
      new_words(board).reduce(player.rack_capacity == @move.size ? 20 : 0) do |total, word|
        total + word.score
      end
    end

    # Check if a move is legal
    def legal?(board, dict, raise_exception = false)
      legal_shape?(board, raise_exception) && legal_words?(board, dict, raise_exception)
    end

    # Check if a move has a legal shape
    def legal_shape?(board, raise_exception = false)
      @shape.legal?(board, raise_exception)
    end

    # Check if all words that result from move are legal
    # TODO: Add the following legal move checks:
    # TODO: - Move is not a simple pluralization? (e.g. Cat -> Cats is NOT a legal move)
    def legal_words?(board, dict, raise_exception = false)
      if can_play_letters?(board, raise_exception)
        bad_words = new_illegal_words(board, dict)
        if bad_words.empty?
          return true
        elsif raise_exception
          raise IllegalMove, "#{bad_words.join(', ')} #{bad_words.size == 1 ? 'is not a legal word' : 'are not legal words'}!"
        end
      end

      false
    end

    # Check if entire move can be played on a board violating any board constraints, such as
    # being out of bounds or exceeding the maximum stack height
    def can_play_letters?(board, raise_exception = false)
      @move.all? do |(row, col), letter|
        board.can_play_letter?(letter, row, col, raise_exception)
      end
    end

    # Check if a particular position (row, col) is covered by the move
    def position?(row, col)
      @move.key?([row, col])
    end

    # Return the letter in position (row, col) of the move
    def [](row, col)
      @move[[row, col]]
    end

    # Play move on board and return the board
    # NOTE: this method mutates the boards!
    # TODO: consider adding the 'can_play_letters?' check?
    def play(board)
      @move.each_with_object(board) do |(posn, letter), b|
        b.play_letter(letter, *posn)
      end
    end

    # Remove a previous move from the board and return the board (throws an exception if the move does not exist on the board)
    # NOTE: this method mutates the boards!
    def remove_from(board)
      if @move.any? { |(row, col), letter| board.top_letter(row, col) != letter }
        raise IllegalMove, 'Move does not exist on board and therefore cannot be removed!'
      else
        @move.each_key.each_with_object(board) do |posn, b|
          b.remove_top_letter(*posn)
        end
      end
    end

    # Return a list of new words that would result from playing this move on the board
    def new_words(board, raise_exception = false)
      if can_play_letters?(board, raise_exception)
        # HACK: update board with new move
        words = board.play_move(self).word_positions.select do |word_posns|
          word_posns.any? { |row, col| position?(row, col) }
        end.map do |word_posns|
          Word.new(word_posns, board)
        end

        # HACK: remove move from board
        remove_from(board)

        words
      end
    end

    # Return a list of new words that are not legal that would result from playing this move on the board
    def new_illegal_words(board, dict)
      new_words(board).reject { |word| dict.legal_word?(word.to_s) }
    end
  end
end
