# N-dimensional array            
module Upwords
  class Box
    include Enumerable
    
    attr_reader :dim, :lengths
    
    # Specify the length of each dimension you wish to initialize
    # Optionally, can specify a default proc to be executed when accessing un-used slots
    def initialize(*dimension_lengths, &block) 
      @lengths = validate_dimension_lengths(dimension_lengths)
      @dim = dimension_lengths.size
      @items = Hash.new(&block)
    end

    def inspect
      "[#{dim}d | #{@items.inspect}]"
    end

    def to_s
      "[#{dim}d | #{@items.to_s}]"
    end
    
    def [](*key)
      @items[validate_key(key)]
    end
    
    def []=(*key, item)
      @items[validate_key(key)] = item
    end

    def delete(*key)
      @items.delete(validate_key(key))
    end

    def length(dim)
      @lengths[dim]
    end

    # map to a new box
    def mapbox(&block)
      return enum_for(__method__) if block.nil?
      new_box = Box.new(*lengths, &@items.default_proc)
      keys.reduce(new_box) do |box, key|
        box[*key] = block.call(self[*key])
        box
      end
    end
    
    def each(&block)
      self.each_key do |key|
        block.call(self[*key])
      end
    end

    def each_key(&block)
      return enum_for(__method__) if block.nil?
      keys.each {|key| block.call(key)}
      return self
    end

    # TODO: How should this work if default_proc exists?
    def map!(&block)
      return enum_for(__method__) if block.nil?
      keys.each do |key|
        self[*key] = block.call(self[*key]) 
      end
    end

    private

    # Return all possible keys of box
    def keys
      first_dim = (0...length(0)).to_a
      if dim == 1
        first_dim
      else
        lengths[1...dim].reduce(first_dim) do |acc, k|
          (acc.product (0...k).to_a)
        end.flatten.each_slice(dim).map do |key|
          key
        end
      end
    end
    
    # Return dimension_lengths if they are valid
    def validate_dimension_lengths(dimension_lengths)
      if dimension_lengths.empty?
        raise ArgumentError, "Must specify length for at least one dimension"
      elsif !(dimension_lengths.all? {|ln| (ln.is_a? Integer) && ln > 0}) 
        raise ArgumentError, "Dimension lengths must be positive integers"
      else
        dimension_lengths
      end
    end
    
    # Return key if it has the same number of dimensions as the box, and all indices are in bounds
    def validate_key(key)
      if !(key.all? {|idx| idx.is_a? Integer})
        raise KeyError, "All key indices must be integers"
      elsif (key.length != dim)
        raise KeyError, "Key must have exactly #{self.dim} dimension(s)"
      else
        bad_idx = find_first_out_of_bounds(key)
        if !bad_idx.nil? 
          raise KeyError, "Key index for dimension #{bad_idx} is out of bounds"
        else
          key
        end
      end
    end

    def find_first_out_of_bounds(key)
      key.each_with_index.find_index {|idx, dim| idx < 0 || idx >= length(dim)}
    end
  end
end
