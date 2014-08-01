require 'rspec_helper'

describe Board do
  
  before :each do
    @board = Board.new
  end

  describe "#new" do
    it "takes zero parameters and returns a Board object" do
        @board.should be_an_instance_of Board
    end
  end

end
