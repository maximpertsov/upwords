require_relative 'lib/upwords'

# TODO: Remove "Max" and "Jordan" after testing is complete
# Upwords::Game.new("Max", "Jordan").run

Upwords::Game.new.run

# Tests

# Board Class
# b = Upwords::Board.new
# puts "Board class: orthogonal_space method"
# puts b.orthogonal_spaces(0,0) - [[0,0], [1,0], [0,1]] == []
# puts b.orthogonal_spaces(1,5) - [[1,5], [0,5], [2,5], [1,4], [1,6]] == []

# Moves Class
# board = Upwords::Board.new
# (3..5).each{|row| board.play_letter("X", row, 3)}
# (3..5).each{|col| board.play_letter("O", 4, col)}

# moves = Upwords::Moves.new(board)
# (3..4).each{|idx| moves.add [idx, 5]}
# moves.add [6,5]

# print moves.legal? 
