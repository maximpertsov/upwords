require 'test_helper'

class BoxTest < Minitest::Test
  extend Minitest::Spec::DSL
  include Upwords

  # def test_init(self):
  #      box = Box(1,2,3)
  #   assert hasattr(box, '__init__')
  #   assert hasattr(box, '__len__')
  #   assert hasattr(box, 'number_of_dimensions')
        
  def test_cannot_init_without_lengths
    assert_raises(ArgumentError) {Box.new}
  end

  def test_cannot_init_with_negative_lengths
    assert_raises(ArgumentError) {Box.new(1, -1, 1)}
    assert_raises(ArgumentError) {Box.new(1, 2, 2, 3, 0)}  
  end

  # Assert that the box length is correct for 1- to 32000-dimensional boxes
  def test_correct_number_of_dimensions
    prng = Random.new
    assert (1..32000).all? do |dim|
      random_lengths = (1..dim).to_a.map{prng.rand(1..500)}
      b = Box.new(*random_lengths)
      b.dim == random_lengths.size
    end
  end

  # ===========================================================
  # TEST GETTING, SETTING, AND DELETING FOR 1-DIMENSIONAL BOXES
  # ===========================================================
  
  # Create a 1-dimensional box with 5 slots
  let(:box1d_empty) { Box.new(5) }

  def test_can_get_indices_1d_box
    b = box1d_empty
    assert_equal b.indices, [0, 1, 2, 3, 4]
  end

  # Create a 1-dimensional box with 5 slots, all filled with the string "X"
  let(:box1d_full) do
    b = Box.new(5)
    (0...b.length(0)).reduce(b) {|b, i| b[i] = "X"; b}
  end
  
  def test_can_set_1d_box
    b = box1d_empty
    assert_silent do
      b.indices.each {|i| b[i] = "X"}
    end
  end

  # Make sure you cannot fill box slots that are out of bounds
  # or that have an incorrect number of dimensions
  def test_cannot_set_1d_box_out_of_bounds
    b = box1d_empty
    assert_raises(KeyError) {b[b.length(0)] = "I'm out of bounds"}
    assert_raises(KeyError) {b[-1] = "I'm out of bounds"}
  end
  
  def test_cannot_set_1d_box_with_wrong_key_dimensions
    assert_raises(KeyError) {box1d_empty[1,2] = "I have the wrong dimensions"}
  end
  
  def test_can_get_from_1d_box
    b = box1d_full
    b.indices.all? {|i| b[i] == "X"}
  end

  def test_set_1d_box_out_of_bounds
    b = box1d_full
    assert_raises(KeyError) {b[b.length(0)]}
    assert_raises(KeyError) {b[-1]}
  end

  def test_cannot_set_1d_box_with_wrong_key_dimensions
    assert_raises(KeyError) {box1d_full[1,2]}
  end
  
  def test_can_delete_from_1d_box
    b = box1d_full
    
    assert_silent do
      b.indices.each {|i| b.delete(i) if i.even?}
    end
    
    b.indices.each do |i|
      if i.even?
        assert_nil b[i]
      else
        assert_equal b[i], "X"
      end
    end
  end

  # ===========================================================
  # TEST GETTING, SETTING, AND DELETING FOR 2-DIMENSIONAL BOXES
  # ===========================================================

  # Create a 2-dimensional box with 3 and 4 slots
  let(:box2d) { Box.new(3,4) }
   
  def test_can_set_2d_box
    # Create 2d box with dimension lengths 3 and 4
    dim_lengths = [3, 4]
    box2d = Box.new(*dim_lengths)
    
    # Fill box with values
    keys = box2d.indices #get_nd_box_keys(*dim_lengths)
    assert_silent do
      keys.each {|i,j| box2d[i,j] = "X"}
    end
           
    # Make sure you cannot fill box slots that are out of bounds
    # or that have an incorrect number of dimensions
    assert_raises(KeyError) {box2d[0, 4] = "I'm out of bounds"}
    assert_raises(KeyError) {box2d[-1, 2] = "I'm out of bounds"}
    assert_raises(KeyError) {box2d[1] = "I have the wrong dimensions"}
  end
  
  def test_get_2d_box
    x, y = 3, 4
    box2d = Box.new(x, y)
    
    # Fill box with values
    keys = box2d.indices # get_nd_box_keys(x, y)
    assert_silent do
      keys.each {|i,j| box2d[i,j] = "X"}
    end
           
    # Check that you can access every box slot that you set
    assert keys.all? do |i,j|
      box2d[i,j] == "X"
    end

    # Make sure you cannot access slots that are out of bounds
    # or that have an incorrect number of dimensions
    assert_raises(KeyError) {box2d[0, 4]}
    assert_raises(KeyError) {box2d[2, -1]}
    assert_raises(KeyError) {box2d[1]}
  end
  
    # def test_del_2d_box(self):
    #     x, y = 3, 4
    #     box2d = Box(x, y)

    #     # Fill box with values
    #     for i, ch1 in enumerate(('a'..'z').to_a[:x]):
    #         for j, ch2 in enumerate(('a'..'z').to_a[:y]):
    #             box2d[i,j] = ''.join([ch1, ch2])

    #     # Delete (odd, even) indices items
    #     for i, ch1 in enumerate(('a'..'z').to_a[:x]):
    #         for j, ch2 in enumerate(('a'..'z').to_a[:y]):
    #             if i % 2 == 1 and j % 2 == 0:
    #                 del box2d[i,j]

    #     # Check that only (odd, even) indices were deleted
    #     for i, ch1 in enumerate(('a'..'z').to_a[:x]):
    #         for j, ch2 in enumerate(('a'..'z').to_a[:y]):
    #             if i % 2 == 1 and j % 2 == 0:
    #                 assert_false((i,j) in box2d) # TODO: move to separate test
    #                 assert_raises(KeyError, box2d.__getitem__, (i, j))
    #             else:
    #                 assert_true((i,j) in box2d)  # TODO: move to separate test
    #                 assert_equal(box2d[i,j], ''.join([ch1, ch2]))
                
   

  # ===========================================================
  # TEST GETTING, SETTING, AND DELETING FOR N-DIMENSIONAL BOXES
  # ===========================================================

end

  
