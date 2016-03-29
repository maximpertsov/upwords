module Upwords
  class Player

    attr_reader :name, :cpu
    attr_accessor :score, :last_turn

    def initialize(name, rack_capacity=7, cpu=false)
      @name = name
      @rack = LetterRack.new(rack_capacity)
      @score = 0
      @last_turn = nil
      @cpu = cpu
    end

    def cpu?
      @cpu
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
    
    # TODO: Strip out move filters and have the client provide them in a block
    def legal_move_shapes(board, &filter) 
      straight_moves(board).select(&filter)
    end
    
    def standard_legal_shape_filter(board)
      proc do |move_arr|
        Shape.new(move_arr).legal?(board)
      end
    end
    
    def legal_shape_letter_permutations(board, &filter)
      # Cache result of letter permutation computation for each move size
      letter_perms = Hash.new {|ps, sz| ps[sz] = letters.permutation(sz).to_a}
      
      legal_move_shapes(board, &filter).reduce([]) do |all_moves, move|
        letter_perms[move.size].reduce(all_moves) do |move_perms, perm|
          move_perms << move.zip(perm)
        end
      end
    end

    def cpu_move(board, dict, sample_size = 1000, min_score = 0)
      all_possible_moves = (self.legal_shape_letter_permutations(board, &self.standard_legal_shape_filter(board)))      
      all_possible_moves.shuffle!

      top_score = 0
      top_score_move = nil

      # TODO: write test for this method
      while top_score_move.nil? || (top_score < min_score) do

        ([sample_size, all_possible_moves.size].min).times do
                    
          move_arr = all_possible_moves.pop
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
