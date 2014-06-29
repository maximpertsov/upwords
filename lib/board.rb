module Upwords
  # 10 x 10 board
  class Board 

    attr_reader :letter_bank

    def initialize
      @grid = Array.new(num_rows) {Array.new(num_columns) { Array.new(max_height)}}
      @letter_bank = LetterBank.new
    end

    def num_columns
      10
    end

    def num_rows
      10
    end

    # maximum letters than can be stacked in one space
    def max_height
      5
    end

    def max_players
      2
    end

    # get number of letters stacked in a board space
    def stack_height(row, col)
      @grid[row][col].compact.size
    end

    # place letter on board space
    def play_letter(letter, row, col)
      height = stack_height(row, col)
      if height >= max_height 
        raise IllegalMove, "You cannot stack any more letters on this space"
      else
        @grid[row][col][height] = letter
      end  
    end

    # get top letter in board space
    def top_letter(row, col)
      current_height = stack_height(row, col)
      if current_height == 0
        nil
      else
        @grid[row][col][current_height - 1]
      end
    end

    # print grid of top letter on each stack and stack height
    def show
      @grid.each_with_index do |row, i| 
        print "\n"
        row.each_index do |j| 
          print "[#{top_letter(i, j)}, #{stack_height(i, j)}] "
        end
      end
      print "\n"
    end
  end
end
