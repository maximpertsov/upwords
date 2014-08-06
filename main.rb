require_relative 'lib/upwords'

# TODO: Remove "Max" and "Jordan" after testing is complete
Upwords::Game.new("Max", "Jordan").run

# Tests

# Board Class
# b = Upwords::Board.new
# puts "Board class: orthogonal_space method"
# puts b.orthogonal_spaces(0,0) - [[0,0], [1,0], [0,1]] == []
# puts b.orthogonal_spaces(1,5) - [[1,5], [0,5], [2,5], [1,4], [1,6]] == []
