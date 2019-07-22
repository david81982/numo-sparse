module Numo
  module Sparse
    class BaseTensor
      def self.max_ndim
        nil
      end

      def initialize(*args)
        case args[0]
        when Numo::NArray
          initialize_with_narray(*args)
        when Array
          initialize_empty(*args)
        else
          raise ArgumentError
        end
      end

      attr_reader :shape, :dtype

      def ndim
        @shape.length
      end

      private def check_shape(shape)
        max_ndim = self.class.max_ndim
        if max_ndim && shape.length > max_ndim
          raise ArgumentError, "Invalid dimension: #{shape}"
        end
        unless shape.all? {|x| x > 0 }
          raise ArgumentError, "Shape has negative values: #{shape}"
        end
        shape
      end

      private def check_dtype(dtype)
        return dtype if dtype < Numo::NArray
        raise ArgumentError, "Invalid dtype: #{dtype}"
      end

      # Returns the transpose of the CSR matrix
      # @return [CSR] transposed matrix in CSR format
      # @example
      #   narray = Numo::DFloat[[1, 0, 2], [0, 0, 3], [4, 5, 6]]
      #   csr = Numo::Sparse::CSR.new(narray)
      #   csr.transpose
      #   # => indices => Numo::Int32[0, 0, 1, 2, 2, 2]
      def transpose()
        self.class.new(data, indices_temp, indptr, shape)
      end
    end
  end
end
