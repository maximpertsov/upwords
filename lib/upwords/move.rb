module Upwords
  class Move

    def initialize(positions, letters)
      if positions.size != letters.size
        raise StandardError, "Must play a letter for each position!"
      else
        @move = positions.zip(letters).to_h
      end
    end

    def [](row, col)
      @move[[row, col]]
    end

    def new_words(board)
      
    end

  end    
end
  
