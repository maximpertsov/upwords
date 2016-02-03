module Upwords
  # 10 x 10 board
  class Board 

    attr_reader :grid, :letter_bank, :moves

    def initialize
      @grid = Array.new(side_length) {Array.new(side_length) {Array.new}}
      @letter_bank = LetterBank.new
    end

    # ---------------
    # Testing methods
    # ---------------
    def inspect
      "I'm an #{num_rows} X #{num_columns} board"
    end

    def to_s
      inspect
    end

    def [](r, c)
      top_letter(r,c)
    end
    # ---------------
    # ---------------
    
    def min_word_length
      2
    end

    def side_length
      10
    end

    # maximum letters than can be stacked in one space
    def max_height
      5
    end
    
    def num_rows
      side_length
    end
    
    def num_columns
      side_length
    end

    # Defines a 2x2 square in the middle of the board (in the case of the 10 x 10 board)
    # The top left corner of the square is the initial cursor position
    # The square itself defines the region where at least one of the first letters must be placed
    def middle_square
      half_len = side_length / 2
      [1, 0].product([1, 0]).map{|i,j| [half_len - i, half_len - j]}
    end

    def stack_height(row, col)
      @grid[row][col].size
    end

    def play_letter(letter, row, col)
      if stack_height(row, col) < max_height
        @grid[row][col] << letter
      else
        raise IllegalMove, "You cannot stack any more letters on this space"
      end  
    end

    def remove_top_letter(row, col)
      @grid[row][col].pop
    end

    # show top letter in board space
    def top_letter(row, col)
      @grid[row][col][-1]
    end

    def words_on_row(row)
      word_posns = group_by_words (0...side_length).map{|col| [row, col]}
      word_posns.map{|posns| Word.new(self, posns)}
    end

    def words_on_rows
      (0...side_length).flat_map{|row| words_on_row row}
    end

    def words_on_column(col)
      word_posns = group_by_words (0...side_length).map{|row| [row, col]}
      word_posns.map{|posns| Word.new(self, posns)}
    end

    def words_on_columns
      (0...side_length).flat_map{|col| words_on_column col}
    end

    def nonempty_spaces
      all_posns = (0...side_length).to_a.product (0...side_length).to_a
      all_posns.select{|row, col| stack_height(row, col) > 0}
    end

    private

    def letters_to_words(letters)
      letters.map{|letter| letter.nil? ? " " : letter}.join.split.reject{|word| word.size < min_word_length}
    end

    # Takes an array of positions and partitions them by empty spaces 
    # Ex. assume positions [[0,0], [0,1], [0,2], [0,3]] correspond to the top letters of ["a", "b", nil, "d"]
    #     then the result of inputing those positions into this method will be [[[0,0],[0,1]],[[0,3]]]
    # This method is used to find words along a row or column
    def group_by_words(posns)
      posns.chunk{|row, col| stack_height(row, col) > 0}.reduce([]) do |words, word|
        if (word[0] && word[1].size >= min_word_length)
          (words << word[1])
        else
          words
        end
      end
    end

  end
end
