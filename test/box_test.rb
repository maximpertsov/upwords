require 'test_helper'
# from random import randrange
# from string import ascii_lowercase

class BoxTest < Minitest::Test
  include Upwords

  # def test_init(self):
  #      box = Box(1,2,3)
  #   assert hasattr(box, '__init__')
  #   assert hasattr(box, '__len__')
  #   assert hasattr(box, 'number_of_dimensions')
        
    # @raises(ValueError)
  def test_cannot_init_without_lengths
    assert_raises(ArgumentError) {Box.new}
  end

  def test_cannot_init_with_negative_lengths
    assert_raises(ArgumentError) {Box.new(1, -1, 1)}
    assert_raises(ArgumentError) {Box.new(1, 2, 2, 3, 0)}  
  end

  # Assert that the box length is correct for 1- to 500-dimensional boxe
  def test_correct_number_of_dimensions
    prng = Random.new
    (1..500).each do |dim|
      rand_lengths = (1..dim).to_a.map{prng.rand(1..500)}
      b = Box.new(*rand_lengths)
      assert b.num_dimensions, rand_lengths.size
    end
  end

  
    # def test_set_1d_box(self):
    #     x = 5
    #     box1d = Box(x)

    #     # Fill box with values
    #     for i, ch in enumerate(ascii_lowercase[:x]):
    #         box1d[i] = ch

    #     # Make sure you cannot fill box slots that are out of bounds
    #     # or that have an incorrect number of dimensions
    #     assert_raises(IndexError, box1d.__setitem__, 5, "I'm out of bounds")
    #     assert_raises(IndexError, box1d.__setitem__, -1, "I'm out of bounds")
    #     assert_raises(KeyError, box1d.__setitem__, (1, 2), "I have the wrong dimensions")

    # def test_get_1d_box(self):
    #     x = 5
    #     box1d = Box(x)

    #     # Fill box with values
    #     for i, ch in enumerate(ascii_lowercase[:x]):
    #         box1d[i] = ch
        
    #     # Check that you can access every box slot that you set
    #     for i, ch in enumerate(ascii_lowercase[:x]):
    #         assert_equal(box1d[i], ch)
            
    #     # Make sure you cannot access slots that are out of bounds
    #     # or that have an incorrect number of dimensions
    #     assert_raises(IndexError, box1d.__getitem__, 5)
    #     assert_raises(IndexError, box1d.__getitem__, -1)
    #     assert_raises(KeyError, box1d.__getitem__, (1, 2))

    # def test_del_1d_box(self):
    #     x = 5
    #     box1d = Box(x)

    #     # Fill box with values
    #     for i, ch in enumerate(ascii_lowercase[:x]):
    #         box1d[i] = ch
        
    #     # Check that you can access every box slot that you set
    #     for i, ch in enumerate(ascii_lowercase[:x]):
    #         assert_equal(box1d[i], ch)
            
    #     # Delete even indices items
    #     for i, ch in enumerate(ascii_lowercase[:x]):
    #         if i % 2 == 0:
    #             del box1d[i]

    #     # Check that only even indices were deleted
    #     for i, ch in enumerate(ascii_lowercase[:x]):
    #         if i % 2 == 0:
    #             assert_raises(KeyError, box1d.__getitem__, i)
    #         else:
    #             assert_equal(box1d[i], ch)

    # def test_set_2d_box(self):
    #     x, y = 3, 4
    #     box2d = Box(x, y)

    #     # Fill box with values
    #     for i, ch1 in enumerate(ascii_lowercase[:x]):
    #         for j, ch2 in enumerate(ascii_lowercase[:y]):
    #             box2d[i,j] = ''.join([ch1, ch2])

    #     # Make sure you cannot fill box slots that are out of bounds
    #     # or that have an incorrect number of dimensions
    #     assert_raises(IndexError, box2d.__setitem__, (0, 4), "I'm out of bounds")
    #     assert_raises(IndexError, box2d.__setitem__, (-1, 2), "I'm out of bounds")
    #     assert_raises(KeyError, box2d.__setitem__, 1, "I have the wrong dimensions")

    # def test_get_2d_box(self):
    #     x, y = 3, 4
    #     box2d = Box(x, y)

    #     # Fill box with values
    #     for i, ch1 in enumerate(ascii_lowercase[:x]):
    #         for j, ch2 in enumerate(ascii_lowercase[:y]):
    #             box2d[i,j] = ''.join([ch1, ch2])
                
    #     # Check that you can access every box slot that you set
    #     for i, ch1 in enumerate(ascii_lowercase[:x]):
    #         for j, ch2 in enumerate(ascii_lowercase[:y]):
    #             assert_equal(box2d[i,j], ''.join([ch1, ch2]))

    #     # Make sure you cannot access slots that are out of bounds
    #     # or that have an incorrect number of dimensions
    #     assert_raises(IndexError, box2d.__getitem__, (0, 4))
    #     assert_raises(IndexError, box2d.__getitem__, (2, -1))
    #     assert_raises(KeyError, box2d.__getitem__, 1)

    # def test_del_2d_box(self):
    #     x, y = 3, 4
    #     box2d = Box(x, y)

    #     # Fill box with values
    #     for i, ch1 in enumerate(ascii_lowercase[:x]):
    #         for j, ch2 in enumerate(ascii_lowercase[:y]):
    #             box2d[i,j] = ''.join([ch1, ch2])

    #     # Delete (odd, even) indices items
    #     for i, ch1 in enumerate(ascii_lowercase[:x]):
    #         for j, ch2 in enumerate(ascii_lowercase[:y]):
    #             if i % 2 == 1 and j % 2 == 0:
    #                 del box2d[i,j]

    #     # Check that only (odd, even) indices were deleted
    #     for i, ch1 in enumerate(ascii_lowercase[:x]):
    #         for j, ch2 in enumerate(ascii_lowercase[:y]):
    #             if i % 2 == 1 and j % 2 == 0:
    #                 assert_false((i,j) in box2d) # TODO: move to separate test
    #                 assert_raises(KeyError, box2d.__getitem__, (i, j))
    #             else:
    #                 assert_true((i,j) in box2d)  # TODO: move to separate test
    #                 assert_equal(box2d[i,j], ''.join([ch1, ch2]))
                
    # # def load_nd_box(self, values, *dim_lengths):
    # #     """Return an n-dimension box with each dimension loaded with values"""

    # # def test_contains
  #
end
