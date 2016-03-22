require 'test_helper'

class MoveTest < Minitest::Test
  include Upwords

  def setup
    @move = Move.new
  end

  def test_make_board
    move_list = [[[1,1,'a'], [1,2,'b'], [1,3,'c']],
                 [[1,1,'d']],
                 [[3,1,'e'], [4,1,'f'], [5,1,'g']]].map do |mv|
      Move.build(mv)
    end

    board = Move.make_board(10, 5, move_list)

    assert_equal 'd', board.top_letter(1, 1)
    assert_equal 2, board.stack_height(1, 1)
    
    assert_equal 'b', board.top_letter(1, 2)
    assert_equal 1, board.stack_height(1, 2)
    
    assert_equal 'c', board.top_letter(1, 3)
    assert_equal 1, board.stack_height(1, 3)

    assert_equal 'e', board.top_letter(3, 1)
    assert_equal 1, board.stack_height(3, 1)

    assert_equal 'f', board.top_letter(4, 1)
    assert_equal 1, board.stack_height(4, 1)

    assert_equal 'g', board.top_letter(5, 1)
    assert_equal 1, board.stack_height(5, 1)
  end

  def test_build
    ms = Move.build([[1,1],[1,2, 'a'],[1,3]])

    assert_kind_of(Move, ms)
    assert_equal 3, ms.size
  end

  def test_union
    ms1 = Move.build([[1,1],[1,2],[1,3]])
    ms2 = Move.build([[1,2],[1,3],[1,4]])

    ms_union = ms1.union(ms2)

    assert_kind_of(Move, ms_union)

    assert_equal 4, ms_union.size
    [[1,1],[1,2],[1,3],[1,4]].each do |r,c|
      assert ms_union.include?(r,c)
    end
  end

  def test_union_of_many
    moves = [
      Move.build([[1,1],[1,2],[1,3]]),
      Move.build([[1,2],[1,3],[1,4]]),
      Move.build([[0,2],[0,3],[0,4]]),
      Move.build([[1,2],[1,3],[1,5]])
    ]

    ms_union = moves.reduce(Move.new) do |ums, ms|
      ms.union(ums)
    end
    
    assert_kind_of(Move, ms_union)

    assert_equal 8, ms_union.size
    
    [[1,1],[1,2],[1,3],[1,4],[1,5],
     [0,2],[0,3],[0,4]].each do |r,c|
      assert ms_union.include?(r,c)
    end
  end

  def test_words
    @move.add(0, 0, 'c')
    @move.add(0, 1, 'a')
    @move.add(0, 2, 't')
    
    @move.add(2, 0, 't')
    @move.add(1, 0, 'o')

    @move.add(9, 0, 'o') # Should skip since it's only one letter

    @move.add(9, 2, 'a')
    @move.add(9, 4, 't')
    @move.add(9, 3, 'r')

    # Check positions
    assert_equal(Set.new([[[0,0], [0,1], [0,2]].to_set,
                          [[0,0], [1,0], [2,0]].to_set,
                          [[9,2], [9,3], [9,4]].to_set]), 
                 @move.word_positions {|w| w.size > 2}.map do |w| 
                   w.map {|mu| mu.posn}.to_set
                 end.to_set)
    
    # Check actual words
    assert_equal(Set.new(['cat', 'cot', 'art']), 
                 @move.words {|w| w.size > 2}.to_set)
  end

  def test_words_after_multiple_moves
    moves = [Move.build([[0, 0, 'c'],
                         [0, 1, 'a'],
                         [0, 2, 't']]),
             Move.build([[0, 2, 't'],
                         [0, 1, 'o']]),
             Move.build([[1, 0, 'a'],
                         [2, 0, 'r'],
                         [3, 0, 't']])]

    # Unify moves
    ms_union = moves.reduce(Move.new) do |ums, ms|
      ms.union(ums)
    end
    
    # Check positions
    assert_equal(Set.new([[[0,0], [0,1], [0,2]].to_set,
                          [[0,0], [1,0], [2,0], [3,0]].to_set]), 
                 ms_union.word_positions {|w| w.size > 2}.map do |w| 
                   w.map {|mu| mu.posn}.to_set
                 end.to_set)
    
    # Check actual words
    assert_equal(Set.new(['cot', 'cart']), 
                 ms_union.words {|w| w.size > 2}.to_set)
  end
  
  def test_covered_word_positions
    board = [[2,4],[3,4],[4,4],
             [2,7],[3,7],[4,7]].reduce(Board.new(10,5)) do |b,(r,c)|
      b.play_letter('x', r, c)
      b
    end
    
    covering_move = Move.build([[2,4],[3,4],[4,4]])

    not_covering_move = Move.build([[2,4],[3,4]])

    assert covering_move.covering_moves?(board)
    refute not_covering_move.covering_moves?(board) 
  end

  def test_gaps_covered_by_other_move?
    broken_move = Move.build([[3, 3], [3, 5]])
    other_move = Move.build([[2, 4], [3, 4], [4, 4]])

    # TODO: make the move-to-board transformation more obvious
    assert broken_move.gaps_covered_by?(Move.make_board([other_move]))
  end

  # def test_covering_breaks?
  #   broken_move = Move.build([[3, 3], [3, 5]])
  #   other_move = Move.build([[2, 4], [3, 4], [4, 4]])
  #   assert other_move.covering_breaks?(broken_move)
  # end
  
  def test_not_touching_previously_played_moves
    board = [[2, 4], [3, 4], [4, 4]].reduce(Board.new) do |b,(r,c)|
      b.play_letter('x', r, c)
      b
    end

    @move.add(2, 0)
    @move.add(3, 0)

    refute @move.touching?(board)
  end

  def test_is_move_in_a_straight_line?
    @move.add(0, 0)
    @move.add(2, 0)
    @move.add(4, 0)
    
    assert @move.straight_line?
  end

  def test_is_move_not_in_a_straight_line?
    @move.add(0, 0)
    @move.add(2, 0)
    @move.add(0, 2)

    refute @move.straight_line?
  end

  def test_row_range
    @move.add(1, 3)
    @move.add(8, 8)
    @move.add(1, 2)
    
    (1..8).each do |r|
      assert_includes @move.row_range, r
    end
  end

  def test_col_range
    @move.add(1, 3)
    @move.add(8, 8)
    @move.add(1, 2)
    
    (2..8).each do |c|
      assert_includes @move.col_range, c
    end
  end

  # def test_gaps
  #   @move.add(1, 3)
  #   @move.add(0, 2)
  
  #   [[0,3],[1,2]].each do |g|
  #     assert_includes @move.gaps, g
  #   end
  # end

  def test_touching?
    @move.add(1, 2)
    @move.add(1, 3)

    board = Board.new(10, 5)
    board.play_letter('x', 0, 2)
    
    assert @move.touching?(board)
  end

  def test_not_touching
    @move.add(1, 3)

    board = Board.new(10, 5)
    board.play_letter('x', 0, 2)
    board.play_letter('x', 8, 8)
    
    refute @move.touching?(board)
  end

  def test_empty?
    assert @move.empty?
  end

  def test_can_add_move
    @move.add(1, 2)
    assert @move.include?(1, 2)
  end
  
end

class MoveUnitTest < Minitest::Test
  include Upwords

  def setup
    @mu_a12 = MoveUnit.new(1, 2)
    @mu_b13 = MoveUnit.new(1, 3)
    @mu_c02 = MoveUnit.new(0, 2)
    @mu_d12 = MoveUnit.new(1, 2)
    @mu_e88 = MoveUnit.new(8, 8)
  end

  def test_hash_equality_aka_eql?
    s = Set.new
    assert_kind_of(Set, s.add?(@mu_a12))
    assert_kind_of(Set, s.add?(@mu_b13))
    assert_nil(s.add?(@mu_d12))
  end

  def test_posn
    assert_equal [1, 2], @mu_a12.posn
    assert_equal [1, 3], @mu_b13.posn
    assert_equal [0, 2], @mu_c02.posn
    assert_equal [1, 2], @mu_d12.posn
    assert_equal [8, 8], @mu_e88.posn
  end
  
  def test_overlaps?
    assert @mu_a12.overlaps? @mu_d12
    refute @mu_a12.overlaps? @mu_b13
  end

  # def test_row_diff
  #   assert_equal 0, @mu_a12.row_diff(@mu_b13)
  #   assert_equal 1, @mu_a12.row_diff(@mu_c02)
  #   assert_equal -1, @mu_c02.row_diff(@mu_b13)
  # end

  # def test_col_diff
  #   assert_equal 0, @mu_a12.col_diff(@mu_c02)
  #   assert_equal -1, @mu_a12.col_diff(@mu_b13)
  #   assert_equal 1, @mu_b13.col_diff(@mu_a12)
  # end

  def test_orthogonal_spaces
    @mu_a12.orthogonal_spaces.each do |sp|
      assert_includes([[0,2],[2,2],[1,1],[1,3]], sp)
    end
  end

  def test_next_to?
    assert @mu_a12.next_to? @mu_b13
    assert @mu_a12.next_to? @mu_c02
    refute @mu_a12.next_to? @mu_e88
    refute @mu_a12.next_to? @mu_d12
  end

end
