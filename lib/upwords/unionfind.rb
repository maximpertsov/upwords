module Upwords
  class UnionFind
    def initialize(keys = [])
      # initialize as empty if 'keys' is not map-able
      keys = keys.respond_to?(:map) ? keys : []     

      @keys = keys.map {|key| [key, true]}.to_h
      @leaders = Hash[@keys.map{|k,v| [k,k]}]
      @ranks = Hash[@keys.map{|k,v| [k,0]}]
    end

    def empty?
      @keys.empty? && @leaders.empty? && @ranks.empty?
    end

    def add(new_key)
      if !@keys.key?(new_key)
        @leaders[new_key] = new_key
        @ranks[new_key] = 0
      end
      @keys[new_key] = true
      new_key
    end

    alias_method :<<, :add
    
    def all_connected?
      @keys.each_key.each_cons(2).all? {|i,j| connected?(i,j)}
    end
    
    def join(i,j)
      if @keys.key?(i) && @keys.key?(j) && !connected?(i,j)
        root1, root2 = find_root(i), find_root(j)
        if @ranks[root1] > @ranks[root2]
          @leaders[root2] = root1
          @ranks[root1] = [@ranks[root1], 1 + @ranks[root2]].max
        else
          @leaders[root1] = root2
          @ranks[root2] = [@ranks[root2], 1 + @ranks[root1]].max  
        end
      end
    end

    def connected?(i,j)
      if @keys.key?(i) && @keys.key?(j)
        find_root(i) == find_root(j)
      end
    end

    def find_root(i)
      if @keys.key?(i)
        compress(i)
        @leaders[i]
      end
    end
    
    private
    
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
