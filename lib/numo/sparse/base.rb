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

      def multiply(matrix)
        data1, indices1, indptr1, shape1= matrix.data, matrix.indices, matrix.indptr, matrix.shape
        if shape[1] == shape1[0]
          matrix1 = self.class.new(data, indices, indptr, shape).to_narray
          matrix2 = matrix.class.new(data1, indices1, indptr1, shape1).to_narray
          new_row, new_col, matrix_row, matrix_col, matrix1_row, matrix1_col, new_matrix_data = 0, 0, 0, 0, 0, 0, 0
          shape2 = [shape[0], shape1[1]]
          narray = data.class.zeros(shape2)
          until new_row == shape[0] do
            until new_col == shape1[1]do
              until matrix_col == shape1[0] do
                new_matrix_data += (matrix1[matrix_row, matrix_col] * matrix2[matrix1_row, matrix1_col])
                matrix_col += 1
                matrix1_row += 1
              end
              narray[new_row, new_col] = new_matrix_data
              new_col += 1
              matrix1_col += 1
              new_matrix_data = 0
              matrix_col = 0
              matrix1_row = 0
            end
            new_col = 0
            matrix1_col = 0
            matrix_row += 1
            new_row += 1
          end
          self.class.new(narray)
        else
        p "Unable to perform matrix multiplication"
        end
      end
    end
  end
end
