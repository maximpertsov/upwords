module Upwords
  class Cursor
    attr_reader :x, :y
    
    def initialize(max_y, max_x, init_y = 0, init_x = 0)
      @max_y = max_y
      @max_x = max_x

      # TODO: Handle case where init_y, x are outside bounds
      @y = init_y 
      @x = init_x
    end

    def move(dy, dx)
      @y = (y + dy) % @max_y
      @x = (x + dx) % @max_x 
    end

    def posn
      [y, x]
    end
  end
end
