require 'test_helper'

class UnionFindTest < Minitest::Test
  include Upwords
  
  def test_it_creates_unionfind_without_arguments
    assert UnionFind.new.is_a? UnionFind
  end

  def test_it_creates_unionfind_from_an_array
    assert UnionFind.new((0..9).to_a).is_a? UnionFind
  end

  def test_it_creates_unionfind_from_a_hash
    assert UnionFind.new({:a=>1,:b=>3}).is_a? UnionFind
  end

  def test_it_does_not_create_unionfind_from_a_number
    begin
      UnionFind.new(1)
    rescue ArgumentError
      assert true
    else
      assert false
    end
  end

  def test_that_all_nodes_are_initially_unconnected
    uf = UnionFind.new((0..99).to_a)
    assert (0..99).each_cons(2).all? {|i,j| !uf.connected?(i,j)}
  end
  
  def test_it_can_return_item_by_key_or_index
    uf = UnionFind.new((0..99).to_a)
    assert uf[0] == 0
  end

  def test_it_can_join_items
    uf = UnionFind.new((0..99).to_a)
    uf.join(0,1)
    assert uf.find_root(0) == 1 && uf.find_root(1) == 1
  end

  def test_it_joins_smaller_groups_to_larger_groups
    uf = UnionFind.new((0..99).to_a)
    uf.join(0,1)
    uf.join(1,2)
    assert uf.find_root(0) == 1 && uf.find_root(1) == 1 && uf.find_root(2) == 1
  end

  def test_it_can_test_for_connectedness
    uf = UnionFind.new((0..99).to_a)
    uf.join(0,1)
    assert uf.connected?(0,1) && !uf.connected?(1,2)
  end  

  def test_it_can_check_all_nodes_are_connected
    uf = UnionFind.new((0..99).to_a)
    (1..98).each{|i| uf.join(i,0)}
    assert !uf.all_connected?
    uf.join(98,99)
    assert uf.all_connected?
  end

  def test_it_can_add_items_without_specifying_a_key
    uf = UnionFind.new((0..99).to_a)
    assert uf << 'a' == 100
    assert uf[100] == 'a'
  end

  def test_it_can_add_items_with_a_key
    uf = UnionFind.new((0..99).to_a)
    assert uf.add('a',-9) == -9
    assert uf[-9] == 'a'
  end

  def test_it_can_add_replace_items
    uf = UnionFind.new((0..99).to_a)
    assert uf.add('a',0) == 0
    assert uf[0] == 'a'
  end
end
