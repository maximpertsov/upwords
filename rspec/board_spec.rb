require '../lib/board.rb'

describe Board do
  
  # before :each do
  #   @board = Board.new
  # end

  @board = Board.new

  describe "board" do

    it "takes zero parameters and returns a Board object" do
      @board.should be_an_instance_of Board
    end

    it "user can see top letter in each space" do
      expect(@board.top_letter(0,0)).to eq(nil)
    end

  end

  #Tests

# require_relative 'upwords'

# b = Upwords::Board.new

# b.play_letter("m", 1, 0)
# b.play_letter("a", 1, 1)
# b.play_letter("x", 1, 3)
# b.play_letter("y", 1, 4)
# b.play_letter("!", 1, 6)

# b.play_letter("x", 2, 1)
# b.play_letter("e", 3, 1)

# ws = b.words_on_rows + b.words_on_columns
# print ws

end
