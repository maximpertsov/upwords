require 'set'

module Upwords
  class Dictionary
  
    def initialize(filepath)
      @legal_words = Set.new
      File.foreach(filepath) {|line| @legal_words << line.chomp.upcase}
      #IO.foreach(filepath) {|line| @legal_words << line.chomp.upcase}
    end

    def legal_word? word
      @legal_words.member? word
    end
    
  end
end
