module Upwords
  class Cursor
    attr_reader :x, :y
    
    def initialize(max_y, max_x, init_y = 0, init_x = 0)
      @max_y = max_y
      @max_x = max_x

      # HACK: Force init_y, init_x to be in bounds
      @y = init_y % @max_y
      @x = init_x % @max_x 
    end

    def up
      move(-1, 0)
    end

    def down
      move(1, 0)
    end

    def left
      move(0, -1)
    end

    def right
      move(0, 1)
    end

    def move(dy, dx)
      @y = (y + dy) % @max_y
      @x = (x + dx) % @max_x 
    end 

    def pos
      [y, x]
    end
  end
end
