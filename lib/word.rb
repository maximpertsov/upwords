module Upwords
  class Word

    attr_reader :text, :positions
    
      def initialize(positions, horizontal)
        @text = text
        @positions = positions
        @horizontal = horizonal
        @visible = false
      end

      def visible?
        @visible
      end
      
      def toggle_visible
        @visible = !@visible
      end
      
      def orthogonal?(other_word)
        other_posns = other_word.positions 
        
      end

      def intersect?(other_word)
        (@positions - other_word.positions).size < @positions.size
      end

      def intersections(other_words)
        other_words.select{|word| self.intersect? word}
      end

      def orthogonal_spaces
        orthogonal_spaces = []
        @pending_moves.each do |posn|
          orthogonal_spaces += [-1,1].collect{|i| [i + posn[0], posn[1]]} + [-1,1].collect{|j| [posn[0], j + posn[1]]}
        end
        orthogonal_spaces.uniq
      end

=begin Graveyard

      # def orthogonal_spaces (position)
      #   @positions.collect{|posn| [posn[dim] + 1, posn[dim] - 1]}.flatten
      # end

      # Checks if word is overlapping or orthogonally adjacent to a board space
      # def touching_space?(position)
      #   posn1, posn2 = self.positions, other_word.positions
      #   def orthogonal?(posn1, posn2)
      #     ((posn1[0] == posn2[0] && (posn1[1] - posn2[1]).abs <= 1) || 
      #      (posn1[1] == posn2[1] && (posn1[0] - posn2[0]).abs <= 1))
      #   end
      # end

      # def orthogonal_spaces
      #   # create offset vectors to generate orthogonal spaces for a horizontal word
      #   body_offset = [[-1,0],[1,0]]
      #   ends_offset = body_offset.collect{|e| e.rotate}
      #   # if word is vertical, then flip offset vectors
      #   if !@horizontal
      #     body_offset, ends_offset = ends_offset, body_offset
      #   end
      #   # generate orthogonal positions
      #   orthogonal_posns = body_offset.collect{|i,j| [i + row, j + col]}
      #   orthogonal_posns
      # end

=end

  end
end
