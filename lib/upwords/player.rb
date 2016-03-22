module Upwords
  class Player

    attr_reader :name
    attr_accessor :score, :skip_count

    def initialize(name, rack_capacity=7)
      @name = name
      @rack = LetterRack.new(rack_capacity)
      @score = 0
      @skip_count = 0
    end

    def letters
      @rack.letters.dup
    end

    def show_rack
      @rack.show
    end

    def show_hidden_rack
      @rack.show_masked
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
        new_letter = letter_bank.draw
        trade_letter = @rack.remove(letter)
        take_letter(new_letter)
        letter_bank.deposit(trade_letter)
      end
    end

    def refill_rack(letter_bank)
      until rack_full? || letter_bank.empty? do
        #while !(rack_full?) && !(letter_bank.empty?) do
        take_letter(letter_bank.draw)
      end
    end
    
    # ----------------
    # CPU Move Methods
    # ----------------
    
    def straight_moves(board)
      rows = board.num_rows
      cols = board.num_columns
      
      # Get single-position moves
      one_space_moves = board.coordinates.map {|posn| [posn]}
      
      # Get board positions grouped by rows
      (0...rows).map do |row| 
        (0...cols).map {|col| [row, col]}
      
      # Get horizontal multi-position moves
      end.flat_map do |posns|
        (2..(letters.size)).flat_map {|sz| posns.combination(sz).to_a}
    
      # Collect all possible straight moves 
      end.reduce(one_space_moves) do |all_moves, move|
        all_moves << move << move.map {|posn| posn.rotate}
      end
    end
    
    def legal_move_shapes(board)
      past_moves = Move.build(board.nonempty_spaces)	
      
      straight_moves(board).select do |move_arr|
        move = Move.build(move_arr)
      
        [board.middle_square.any? { |posn| move_arr.include?(posn) },
         move.gaps_covered_by?(past_moves),
         (past_moves.empty? || move.touching?(past_moves)),
         !(move.covering_moves?(past_moves) {|w| w.size >= 2})].all?
      end
    end
    
    def legal_shape_letter_permutations(board)
      # Cache result of letter permutation computation for each move size
      letter_perms = Hash.new {|ps, sz| ps[sz] = letters.permutation(sz).to_a }

      legal_move_shapes(board).reduce([]) do |all_moves, move|
        letter_perms[move.size].reduce(all_moves) do |move_perms, perm|
          move_perms << move.zip(perm)
        end
      end
    end
    
  end
end
