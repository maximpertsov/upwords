module Upwords
  class Player

    attr_reader :name, :score, :cursor_posn

    def initialize(game, player_name)
      #@game = game
      @name = player_name
      @board = game.board
      @score = 0
      @cursor_posn = @board.middle_square[0]
      @pending_moves = game.moves
      @letter_bank = game.letter_bank
      
      @rack = LetterRack.new(capacity=7)
      @rack.refill(@letter_bank)
    end

    def show_rack
      @rack.show
    end

    def show_hidden_rack
      '* ' * @rack.rack.size
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
          @board.play_letter(selected_letter, *@cursor_posn)
          @pending_moves.add(@cursor_posn)
        end
      rescue IllegalMove => exception
        @rack.return_to(selected_letter)
        raise IllegalMove, exception.message
      end
    end

    def show_pending_moves
      @pending_moves.pending_result
    end

    def swap_letter(letter)
      undo_moves
      @rack.swap(letter, @letter_bank)
    end

    def refill_rack
      @rack.refill(@letter_bank)
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
      if @pending_moves.legal?
        @score += @pending_moves.pending_score
        @pending_moves.clear
        refill_rack
        @pending_moves.update_moves
      end
    end
    
  end
end
