module Upwords
  class Word

    attr_reader :text, :positions, :final
    
      def initialize(text = "", positions = [])
        @text = text
        @positions = positions
        @final = false
        @visible = false
      end

      def visible?
        @visible
      end
      
      def make_final
        final = true
      end
      
      def toggle_visible
        @visible = !@visible
      end

  end
end
