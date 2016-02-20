require 'test_helper'

class UnionFindTest < Minitest::Test
  include Upwords

  def setup
    @uf = UnionFind.new(0..99)
  end
  
  def test_it_creates_unionfind_without_arguments
    assert UnionFind.new.is_a? UnionFind
  end

  def test_it_creates_unionfind_from_an_array
    assert UnionFind.new((0..9).to_a).is_a? UnionFind
  end

  def test_it_creates_unionfind_from_a_hash
    assert UnionFind.new({:a=>1,:b=>3}).is_a? UnionFind
  end

  def test_it_creates_an_empty_unionfind_from_a_number
    @uf = UnionFind.new(1)
    assert @uf.empty?
    assert_kind_of(UnionFind, @uf)
  end
  
  def test_that_all_nodes_are_initially_unconnected
    assert (0..99).each_cons(2).all? do |i,j|
      !@uf.connected?(i,j)
    end
  end
  
  # def test_it_can_return_item_by_key_or_index
  #   uf = UnionFind.new((0..99).to_a)
  #   assert_equal 0, uf[0]
  # end

  def test_can_add_new_keys
    assert_equal 100, @uf.add(100)
    assert_equal 100, @uf.find_root(100)
  end

  def test_can_add_new_keys_alias
    assert_equal 100, (@uf << 100)
    assert_equal 100, @uf.find_root(100)
  end

  def test_cannot_add_existing_key
    assert_raises(KeyError) {@uf.add(1)}
  end

  def test_it_can_join_items
    @uf.join(0,1)
    assert_equal 1, @uf.find_root(0)
    assert_equal 1, @uf.find_root(1)
  end

  def test_it_joins_smaller_groups_to_larger_groups
    @uf.join(0,1)
    @uf.join(1,2)
    assert_equal 1, @uf.find_root(0)
    assert_equal 1, @uf.find_root(1)
    assert_equal 1, @uf.find_root(2)
  end

  def test_it_can_test_for_connectedness
    @uf.join(0,1)
    assert @uf.connected?(0,1)
    refute @uf.connected?(1,2)
  end  

  def test_it_can_check_all_nodes_are_connected
    (1..98).each{|i| @uf.join(i,0)}
    refute @uf.all_connected?

    @uf.join(98,99)
    assert @uf.all_connected?
  end

  # def test_it_can_add_items_without_specifying_a_key
  #   uf = UnionFind.new((0..99).to_a)
  #   assert uf << 'a' == 100
  #   assert uf[100] == 'a'
  # end

  # def test_it_can_add_items_with_a_key
  #   uf = UnionFind.new((0..99).to_a)
  #   assert uf.add('a',-9) == -9
  #   assert uf[-9] == 'a'
  # end

  # def test_it_can_add_replace_items
  #   uf = UnionFind.new((0..99).to_a)
  #   assert uf.add('a',0) == 0
  #   assert uf[0] == 'a'
  # end
end
