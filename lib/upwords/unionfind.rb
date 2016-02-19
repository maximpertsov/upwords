module Upwords
  class UnionFind
    def initialize(items={})
      @items = add_keys(items)
      @leaders = Hash[@items.map{|k,v| [k,k]}]
      @ranks = Hash[@items.map{|k,v| [k,0]}]
    end
    
    def [](key)
      @items[key]
    end

    # add new item to unionfind and return associated item key
    def add(item, key=nil)
      new_key = key.nil? ? @items.keys.max + 1 : key
      if !@items.key?(new_key)
        @leaders[new_key] = new_key
        @ranks[new_key] = 0
      end
      @items[new_key] = item
      new_key
    end

    alias_method :<<, :add
    
    def all_connected?
      @items.each_key.each_cons(2).all? {|i,j| connected?(i,j)}
    end
    
    def join(i,j)
      if @items.key?(i) && @items.key?(j) && !connected?(i,j)
        root1, root2 = find_root(i), find_root(j)
        if @ranks[root1] > @ranks[root2]
          @leaders[root2] = root1
          @ranks[root1] = [@ranks[root1], 1+ @ranks[root2]].max
        else
          @leaders[root1] = root2
          @ranks[root2] = [@ranks[root2], 1 + @ranks[root1]].max  
        end
      end
    end

    def connected?(i,j)
      if @items.key?(i) && @items.key?(j)
        find_root(i) == find_root(j)
      end
    end

    def find_root(i)
      if @items.key?(i)
        compress(i)
        @leaders[i]
      end
    end
    
    private
    def add_keys(items)
      if items.is_a? Hash
        if items.empty?
          @items = {}
        else
          @items = Hash.new(items)
        end
      elsif items.is_a? Array
        @items = Hash[items.each_with_index.map{|elem,i| [i, elem]}]
      else
        raise ArgumentError, "Must initialize with array or hash"
      end
    end
    
    def path_to_root(i)
      chain = [i]
      while chain[-1] != @leaders[chain[-1]]
        chain << @leaders[chain[-1]]
      end
      chain
    end

    def compress(i)
      chain = path_to_root(i)
      main_leader = chain[-1]
      chain.each{|j| @leaders[i] = main_leader}
    end
  end
end
