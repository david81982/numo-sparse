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

      # Returns the row of the CSR matrix
      # @param row [scalar] Which row will be returned
      # @return [CSR] Row of the matrix in CSR format
      # @example
      #   narray = Numo::DFloat[[1, 0, 2], [0, 0, 3], [4, 5, 6]]
      #   csr = Numo::Sparse::CSR.new(narray)
      #   csr.get_row(1)
      #   # => data => [3], indices => [2], indptr => [0, 1]
      def get_row(row)
        max_col, curr_col, row = shape[1], 0, row
        matrix = self.class.new(data, indices, indptr, shape).to_narray
        result = data.class.zeros([1, max_col])
        until curr_col == max_col do
          if matrix[row, curr_col] != 0
            result[0, curr_col] = matrix[row, curr_col]
          end
          curr_col += 1
        end
        self.class.new(result)
      end
    end
  end
end
