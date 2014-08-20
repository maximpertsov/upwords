require 'spec_helper'

describe Upwords::Board do
  
  before :each do
    @board = Upwords::Board.new
  end

  it "takes zero parameters and returns a Board object" do
    expect(@board).to be_an_instance_of(Upwords::Board)
  end

  describe "#top_letter" do # hash (#) for instance methods and dot (.) for class methods

    #can add some more 'before' conditions

    context "with no letters in space" do
      it { expect(@board.top_letter(0,0)).to eq(nil) }
    end  

    context "with letters in space" do
      before :each do
        @board.play_letter("m", 1, 0)
      end
    
      it { expect(@board.top_letter(1,0)).to eq("m") }
    
    end
  end    
end

# Other notes: can use 'context' blocks

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

