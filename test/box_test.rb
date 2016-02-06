require 'test_helper'

class BoxTest < Minitest::Test
  include Upwords
        
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

  class Box1DTest < Minitest::Test
    include Upwords
    
    def setup
      @box = Box.new(5)
    end

    def test_has_correct_dimension
      assert_equal 1, @box.dim 
    end
    
    def test_has_correct_dimension_lengths
      assert_equal 5, @box.length(0)
      assert_equal [5], @box.lengths
    end

    def test_can_iterate_through_keys
      expected_keys = (0..4).to_a
      @box.each_key.each_with_index do |key, i|
        assert_equal expected_keys[i], key
      end
    end

    def test_can_iterate_through_items
      expected_items = (0..4).map {|i| @box[i]}
      @box.each_with_index do |item, i|
        assert_equal expected_items[i], item
      end
    end

    def test_can_return_items_in_array
      assert_equal [nil, nil, nil, nil, nil], @box.to_a
    end

    def test_can_map_items_to_a_new_array
      assert_equal ["A", "A", "A", "A", "A"], @box.map {|item| "A"}
      assert_equal [0, 2, 4, 6, 8], @box.each_key.map {|key| 2 * key}
    end

    def test_can_set_and_get_at_index
      @box[0] = "A"
      @box[1] = "B"
      @box[4] = "C"
      @box[4] = "D" # Overwritten
      
      assert_equal ["A", "B", nil, nil, "D"], @box.to_a
    end

    def test_can_set_all_slots_with_map!
      @box.map! {|x| "A"}
      assert_equal ["A", "A", "A", "A", "A"], @box.to_a
    end
    
    def test_can_delete_at_index
      @box.map! {|x| "X"}
      
      @box.delete(0)
      @box.delete(4)
      
      assert_equal [nil, "X", "X", "X", nil], @box.to_a
    end
    
    def test_can_map_to_new_box
      b = @box.mapbox {|x| "A"}
      
      assert_instance_of @box.class, b
      assert_equal ["A", "A", "A", "A", "A"], b.to_a 
      assert_equal [nil, nil, nil, nil, nil], @box.to_a
    end
    
    def test_cannot_set_with_non_int_arguments
      assert_raises(KeyError) {@box['a'] = "I'm not a valid key"}
      assert_raises(KeyError) {@box[3.0] = "I'm not a valid key"}
    end
    
    def test_cannot_set_out_of_bounds_index
      assert_raises(KeyError) {@box[5] = "I'm out of bounds"}
      assert_raises(KeyError) {@box[-1] = "I'm out of bounds"}
    end
    
    def test_cannot_set_with_wrong_key_dimensions
      assert_raises(KeyError) {@box[1,2] = "I have the wrong dimensions"}
      assert_raises(KeyError) {@box[] = "I have the wrong dimensions"}
      assert_raises(KeyError) {@box[1,2,2] = "I have the wrong dimensions"}
    end
  end

  # ===========================================================
  # TEST GETTING, SETTING, AND DELETING FOR 2-DIMENSIONAL BOXES
  # ===========================================================

  # # Create a 2-dimensional box with 3 and 4 slots
  # let(:box2d) { Box.new(3,4) }
   
  # def test_can_set_2d_box
  #   # Create 2d box with dimension lengths 3 and 4
  #   dim_lengths = [3, 4]
  #   box2d = Box.new(*dim_lengths)
    
  #   # Fill box with values
  #   keys = box2d.indices #get_nd_box_keys(*dim_lengths)
  #   assert_silent do
  #     keys.each {|i,j| box2d[i,j] = "X"}
  #   end
           
  #   # Make sure you cannot fill box slots that are out of bounds
  #   # or that have an incorrect number of dimensions
  #   assert_raises(KeyError) {box2d[0, 4] = "I'm out of bounds"}
  #   assert_raises(KeyError) {box2d[-1, 2] = "I'm out of bounds"}
  #   assert_raises(KeyError) {box2d[1] = "I have the wrong dimensions"}
  # end
  
  # def test_get_2d_box
  #   x, y = 3, 4
  #   box2d = Box.new(x, y)
    
  #   # Fill box with values
  #   keys = box2d.indices # get_nd_box_keys(x, y)
  #   assert_silent do
  #     keys.each {|i,j| box2d[i,j] = "X"}
  #   end
           
  #   # Check that you can access every box slot that you set
  #   assert keys.all? do |i,j|
  #     box2d[i,j] == "X"
  #   end

  #   # Make sure you cannot access slots that are out of bounds
  #   # or that have an incorrect number of dimensions
  #   assert_raises(KeyError) {box2d[0, 4]}
  #   assert_raises(KeyError) {box2d[2, -1]}
  #   assert_raises(KeyError) {box2d[1]}
  # end
  
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

  
