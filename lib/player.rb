module Upwords
  class Player

    attr_reader :name, :score, :cursor_posn

    def initialize(board, player_name)
      @name = player_name
      @board = board
      @rack = LetterRack.new(board.letter_bank)
      @score = 0
      @cursor_posn = @board.middle_square[0]
      @pending_moves = Moves.new(@board)
    end

    def show_rack
      @rack.show
    end

    def move_cursor(move_vector)
      max_move = [@board.num_rows, @board.num_columns]
      move_vector.each_with_index do |move, idx|
        @cursor_posn[idx] = (@cursor_posn[idx] + move) % max_move[idx]
      end 
    end

    def play_letter(letter)
      selected_letter = @rack.take_from(letter)
      begin
        if @pending_moves.include? @cursor_posn 
          raise IllegalMove, "You can't stack on a space more than once in a single turn!"
        else
          @board.play_letter(selected_letter, @cursor_posn[0], @cursor_posn[1])
          @pending_moves.add(@cursor_posn)
        end
      rescue IllegalMove => exception
        @rack.return_to(selected_letter)
        raise IllegalMove, exception.message
      end
    end

    def word_so_far
      @pending_moves.get_word
    end

    def swap_letter(letter)
      @rack.swap(letter)
    end

    def refill_rack
      @rack.refill
    end

    def undo_moves
      while has_pending_moves? do
        @rack.return_to(@pending_moves.undo_last)
      end
    end

    def has_pending_moves?
      !@pending_moves.empty?
    end

    def submit_moves
      @pending_moves.clear
    end
    
  end
end
