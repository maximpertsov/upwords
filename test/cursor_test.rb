require 'test_helper'

class CursorTest < Minitest::Test
  include Upwords

  def setup
    @cursor = Cursor.new(5, 5, 0, 0)
  end

  def test_init_pos
    assert_equal [0,0], Cursor.new(5, 5).pos
    assert_equal [1,4], Cursor.new(5, 5, 1, 4).pos
  end
  
  def test_move
    @cursor.move(1, 1)
    assert_equal [1, 1], @cursor.pos

    # wrap around top
    @cursor.move(-2, 0)
    assert_equal [4, 1], @cursor.pos

    # wrap around left
    @cursor.move(0, -3)
    assert_equal [4, 3], @cursor.pos

    # wrap around bottom
    @cursor.move(1, 0)
    assert_equal [0, 3], @cursor.pos

    # wrap around right
    @cursor.move(0, 4)
    assert_equal [0, 2], @cursor.pos
  end
end
