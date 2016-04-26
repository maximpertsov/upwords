# Encapsules a player
# Contains basic AI logic

module Upwords
  class Player

    attr_reader :name
    attr_accessor :score, :last_turn

    def initialize(name, rack_capacity=7, cpu=false)
      @name = name
      @rack = LetterRack.new(rack_capacity)
      @score = 0
      @last_turn = nil
      @cpu = cpu
    end

    def letters
      @rack.letters.dup
    end

    def show_rack(masked = false)
      masked ? @rack.show_masked : @rack.show
    end

    def rack_full?
      @rack.full?
    end

    def rack_empty?
      @rack.empty?
    end

    def rack_capacity
      @rack.capacity
    end

    def take_letter(letter)
      @rack.add(letter)
    end
    
    # -------------------------------
    # Game object interaction methods
    # -------------------------------

    def take_from(board, row, col)
      if board.stack_height(row, col) == 0
        raise IllegalMove, "No letters in #{row}, #{col}!"
      else
        take_letter(board.remove_top_letter(row, col))
      end
    end

    def play_letter(board, letter, row, col)
      rack_letter = @rack.remove(letter)
      begin
        board.play_letter(rack_letter, row, col)
      rescue IllegalMove => exn
        take_letter(rack_letter)
        raise IllegalMove, exn
      end
    end

    def swap_letter(letter, letter_bank)
      if letter_bank.empty?
        raise IllegalMove, "Letter bank is empty!"
      else
        trade_letter = @rack.remove(letter)
        take_letter(letter_bank.draw)
        letter_bank.deposit(trade_letter)
      end
    end

    def refill_rack(letter_bank)
      until rack_full? || letter_bank.empty? do
        take_letter(letter_bank.draw)
      end
    end
    
    # ---------------
    # AI move methods
    # ---------------
    
    def cpu?
      @cpu
    end
    
    # Return a list of legal move shapes that player could make on board
    def legal_move_shapes(board)
      one_space_moves = board.coordinates.map {|posn| [posn]}
      
      # Collect board positions grouped by rows
      (0...board.num_rows).map do |row| 
        (0...board.num_columns).map {|col| [row, col]} 
        
      # Collect all positions of all possible horizontal multi-position moves that player could make
      end.flat_map do |posns|
        (2..(letters.size)).flat_map {|sz| posns.combination(sz).to_a}
        
      # Collect all positions of all possible vertical and horizontal moves that player could make
      end.reduce(one_space_moves) do |all_moves, move|
        all_moves << move                           # Horizontal moves
        all_moves << move.map {|posn| posn.rotate}  # Vertical moves
      
      # Filter out illegal move shapes  
      end.select |move_posns|
        Shape.new(move_posns).legal?(board)
      end
    end
    
    # Return list of all possible letter permutations on legal move shapes that player could make on board
    # Elements in the list will be in form of [(row, col), letter]
    def legal_move_shapes_letter_permutations(board)
      # Cache result of letter permutation computation for each move size
      letter_perms = Hash.new {|perms, sz| perms[sz] = letters.permutation(sz).to_a}
      
      legal_move_shapes(board).reduce([]) do |all_moves, move|
        letter_perms[move.size].reduce(all_moves) do |move_perms, perm|
          move_perms << move.zip(perm)
        end
      end
    end

    # Execute a legal move based on a predefined strategy
    #
    # Basic strategy:
    # - Find all legal move shapes and all possible letter permutations across those shapes (this computation is relatively quick)
    # - Retun the highest score from permutation that do not produce in any illegal new words (this computation is slow...)
    # - To speed up the above computation: 
    #   + Only check a batch of permutations at a time (specified in 'batch_size' argument)
    #   + After each batch, terminate the subroutine if it finds a score that is at least as high as the given 'min_score'
    #   + Decrement the 'min_score' after each batch that does not terminate the subroutine to prevent endless searches
    #
    # TODO: refactor the the 'strategy' component out of this method, so different strategies can be swapped in and out
    def cpu_move(board, dict, batch_size = 1000, min_score = 0)
      possible_moves = self.legal_move_shapes_letter_permutations(board)      
      possible_moves.shuffle!

      top_score = 0
      top_score_move = nil

      while top_score_move.nil? || (top_score < min_score) do
        
        # Check if next batch contains any legal moves and save the top score
        ([batch_size, possible_moves.size].min).times do
          move_arr = possible_moves.pop
          move = Move.new(move_arr)

          if move.legal_words?(board, dict)
            move_score = move.score(board, self)
            if move_score >= top_score
              top_score = move_score
              top_score_move = move_arr
            end
          end
        end
        
        # Decrement minimum required score after each cycle to help prevent long searches
        min_score = [(min_score - 1), 0].max
      end

      top_score_move
    end
    
  end
end
