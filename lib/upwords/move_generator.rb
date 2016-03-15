module Upwords
  module MoveGenerator
    
    def self.union_moves(moves)
      moves.reduce(Move.new) {|ms, m| m.union(ms)}
    end

    def self.play_move(board, move)
      move.each do |mu|
        board.player_letter(mu.letter, mu.row, mu.col)
      end
    end

    def self.generate_board(size, moves)
      b = Board.new(size)
      moves.each {|m| b.play_move(m)}
      return b
    end

  end

end

