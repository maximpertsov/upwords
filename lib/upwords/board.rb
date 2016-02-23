require 'matrix'

module Upwords
  class Board
    
    # creates a 10 x 10 board
    def initialize(size=10)
      @grid = Matrix.build(size) { [] }
    end
    
    # maximum letters than can be stacked in one space
    def min_word_length
      2
    end

    def max_height
      5
    end
    
    def side_length
      @grid.row_size
    end
    
    def num_rows
      @grid.row_size
    end
    
    def num_columns
      @grid.column_size
    end

    # Defines a 2x2 square in the middle of the board (in the case of the 10 x 10 board)
    # The top left corner of the square is the initial cursor position
    # The square itself defines the region where at least one of the first letters must be placed
    def middle_square
      half_len = side_length / 2
      [1, 0].product([1, 0]).map{|i,j| [half_len - i, half_len - j]}
    end

    def stack_height(row, col)
      @grid[row, col].size
    end

    def play_letter(letter, row, col)
      if stack_height(row, col) < max_height
        @grid[row, col] << letter #MoveUnit.new(letter, row, col)
      else
        raise IllegalMove, "You cannot stack any more letters on this space"
      end  
    end

    def remove_top_letter(row, col)
      @grid[row, col].pop
      #@grid[row, col].pop.letter unless @grid[row, col].empty?
    end
  
    # show top letter in board space
    def top_letter(row, col)
      @grid[row, col][-1]
      #top_tile(row, col).letter unless top_tile(row, col).nil?
    end

    def words
      words_on_rows + words_on_columns
    end

    def nonempty_spaces
      coordinates.select {|row, col| stack_height(row, col) > 0}
    end

    # # TODO: Not used yet
    # def pending_moves
    #   nonempty_spaces.reject {|row, col| top_tile(row, col).final?}
    # end

    # # TODO: Not used yet
    # def final_moves
    #   nonempty_spaces.reject do |row, col|
    #     top_final_tile(row, col).nil?
    #   end
    # end

    # # TODO: Not used yet
    # def finalize!
    #   pending_moves.each {|row, col| top_tile(row, col).finalize!}
    # end
    
    private

    # def top_tile(row, col)
    #   @grid[row, col][-1]
    # end

    # def top_final_tile(row, col)
    #   @grid[row, col].select{|m| m.final?}[-1]
    # end
    
    # Takes an array of positions and partitions them by empty spaces 
    # Ex. assume positions [[0,0], [0,1], [0,2], [0,3]] correspond to the top letters of ["a", "b", nil, "d"]
    #     then the result of inputing those positions into this method will be [[[0,0],[0,1]],[[0,3]]]
    # This method is used to find words along a row or column
    def collect_words(posns)
      posns.chunk {|row, col| stack_height(row, col) > 0}.reduce([]) do |words, (is_word, letter_posns)|
        if is_word && letter_posns.size >= min_word_length
          words << Word.new(self, letter_posns)
        end
        words
      end
    end

    def words_on_row(row)
      collect_words (0...num_columns).map{|col| [row, col]}
    end

    def words_on_rows
      (0...num_rows).flat_map{|row| words_on_row(row)}
    end

    def words_on_column(col)
      collect_words (0...num_rows).map{|row| [row, col]}
    end

    def words_on_columns
      (0...num_columns).flat_map{|col| words_on_column(col)}
    end
    
    def coordinates
      @grid.each_with_index.map {|e, row, col| [row, col]}
    end    
  end
end
