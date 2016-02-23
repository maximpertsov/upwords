module Upwords
  class Dictionary

    def initialize(words = [])
      @legal_words = Set.new(words.map {|w| w.upcase})
    end
    
    def self.import(filepath)
      dict = Dictionary.new
      File.foreach(filepath) do |line|
        dict << line.chomp
      end
      dict
    end

    def legal_word? word
      @legal_words.member? (word.upcase)
    end

    def add_word word
      @legal_words.add? (word.upcase)
    end

    alias_method :<<, :add_word

    def remove_word word
      @legal_words.delete? (word.upcase)
    end
    
  end
end
