module Upwords
  class Dictionary
  
    def initialize(filepath)
      # TODO: make 'a' a word list file that gets read in
      a = %w(a b c)
      @dict = a.reduce({}) do |memo, line|
        memo[line] = true
        memo
      end
    end

    def word_found? word
      !!@dict[word]
    end
  
  end
end
