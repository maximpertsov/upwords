# N-dimensional array            
module Upwords
  class Box
    attr_reader :num_dimensions
    
    # Specify the length of each dimension you wish to initialize
    def initialize(*dimension_lengths)
      @dimension_lengths = validate_dimension_lengths(dimension_lengths)
      @num_dimensions = dimension_lengths.size
      @items = {}
    end    
    
    def [](*key)
      @items[validate_key(key)]
    end
    
    def []=(*key, item)
      @items[validate_key(key)] = item
    end

    def length(dim)
      @dimension_lengths[dim]
    end

    private
    
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

    def same_dimensions?(key)
      key.length != num_dimensions
    end

    # TODO: fix me
    def find_out_of_bounds(key)
      key.each_with_index.find_index {|idx, dim| idx < 0 || idx >= length(dim)}
    end
    
    # Return key if it has the same number of dimensions as the box, and all indices are in bounds
    def validate_key(key)
      if same_dimensions?(key)
        raise KeyError, "Key must have exactly #{self.num_dimensions} dimension(s)"
      else
        bad_idx = find_out_of_bounds(key)
        if !bad_idx.nil? 
          raise KeyError, "Key index for dimension #{bad_idx} is out of bounds"
        else
          key
        end
      end
    end
  end
end
