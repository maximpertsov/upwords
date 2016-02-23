require 'test_helper'

class DictionaryTest < Minitest::Test
  include Upwords

  class BasicDictionaryTest < DictionaryTest 
    def setup
      @dict = Dictionary.new(['cat', 'rat', 'fat'])
    end

    def test_legal_word?
      assert @dict.legal_word?('cat')
      assert @dict.legal_word?('rat')
      assert @dict.legal_word?('fat')
      refute @dict.legal_word?('cow')
    end

    def test_can_add_word
      @dict.add_word 'cow'
      assert @dict.legal_word?('cow')
      
      @dict << 'wow'
      assert @dict.legal_word?('wow')
    end
    
    def test_can_remove_word
      @dict.remove_word('cat')
      refute @dict.legal_word?('cat')
    end
  end

  class ImportDictionaryTest < DictionaryTest   
    def test_can_import_words_from_file
      File.open('test/data/dict_test.txt', 'w') do |f|
        f.write("cat\nrat\nfat")
      end
      
      new_dict = Dictionary.import('test/data/dict_test.txt')
      
      assert new_dict.legal_word?('cat')
      assert new_dict.legal_word?('rat')
      assert new_dict.legal_word?('fat')
      refute new_dict.legal_word?('cow')
    end
  end
end
