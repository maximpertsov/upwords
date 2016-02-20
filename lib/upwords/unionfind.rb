module Upwords
  class UnionFind
    def initialize(keys = [])
      # initialize as empty if 'keys' is not map-able
      keys = keys.respond_to?(:map) ? keys : []     
      @leaders = keys.map {|k| [k,k]}.to_h
      @ranks = keys.map {|k| [k,0]}.to_h
    end

    def inspect
      @leaders.inspect
    end
    
    def to_s
      @leaders.to_s
    end
    
    def empty?
      @leaders.empty? && @ranks.empty?
    end

    def add(new_key)
      if @leaders.key?(new_key)
        raise KeyError, "Key already exists!"
      else
        @ranks[new_key] = 0
        @leaders[new_key] = new_key
      end
    end

    alias_method :<<, :add
    
    def all_connected?
      @leaders.each_key.each_cons(2).all? {|i,j| connected?(i,j)}
    end
    
    def join(i,j)
      if @leaders.key?(i) && @leaders.key?(j) && !connected?(i,j)
        root1, root2 = find_root(i), find_root(j)
        if @ranks[root1] > @ranks[root2]
          @leaders[root2] = root1
          @ranks[root1] = [@ranks[root1], @ranks[root2] + 1].max
        else
          @leaders[root1] = root2
          @ranks[root2] = [@ranks[root2], @ranks[root1] + 1].max  
        end
      end
    end

    def connected?(i,j)
      if @leaders.key?(i) && @leaders.key?(j)
        find_root(i) == find_root(j)
      end
    end

    def find_root(i)
      if @leaders.key?(i)
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
