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

      def get_col(col)
        max_rows, curr_row, col = shape[0], 0, col
        matrix = self.class.new(data, indices, indptr, shape).to_narray
        result = data.class.zeros([max_rows, 1])
        until curr_row == max_rows do
          if matrix[curr_row, col] != 0
            result[curr_row, 0] = matrix[curr_row, col]
          end
          curr_row += 1
        end
        self.class.new(result)
      end
    end
  end
end
