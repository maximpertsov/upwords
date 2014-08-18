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

end
