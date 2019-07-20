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

#this is new
      # Converts the sparse matrix into a normal array
      # @return [narray] the matrix from CSR
      # @example
      #   narray = Numo::DFloat[[1, 0, 2], [0, 0, 3], [4, 5, 6]]
      #   csr = Numo::Sparse::CSR.new(narray)
      #   csr.to_narray
      #   # => Numo::DFloat[[1, 0, 2], [0, 0, 3], [4, 5, 6]]
      def to_narray()
        narray = data.class.zeros(shape)
        row, row_lim, curr_ind = 0, 0, 0
        curr_data, current, curr_ptr = 0, 0, 1
        while row < (indptr.size - 1)
          row_lim = (indptr[curr_ptr] - indptr[curr_ptr-1])
          while current < row_lim
            narray[row, indices[curr_ind]] = data[curr_data]
            curr_ind += 1
            curr_data += 1
            current += 1
          end
          curr_ptr += 1
          row += 1
          current = 0
        end
        narray
      end

#this is new
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

#this is new
      # Returns the column of the CSR matrix
      # @param col [scalar] Which column will be returned
      # @return [CSR] Column of the matrix in CSR format
      # @example
      #   narray = Numo::DFloat[[1, 0, 2], [0, 0, 3], [4, 5, 6]]
      #   csr = Numo::Sparse::CSR.new(narray)
      #   csr.get_col(1)
      #   # => data => [5], indices => [0], indptr => [0, 0, 0, 1]
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

#this is new
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

#this is new
      # Multiplies matrix by scalar
      # @param scalar [scalar] amount that the matrix will be multiplied by
      # @return [sparse matrix] creates the new multiplied sparse matrix
      # @example
      #   narray = Numo::DFloat[[1, 0, 2], [0, 0, 3], [4, 5, 6]]
      #   csr = Numo::Sparse::CSR.new(narray)
      #   csr * 2
      #   # => data => [2, 4, 6, 8, 10, 12]
      def *(scalar)
        new_data = data * scalar
        new_indices = indices.dup
        new_indptr = indptr.dup
        new_shape = shape.dup
        self.class.new(new_data, new_indices, new_indptr, new_shape)
      end

      #this is new
      # Multiplies matrix by matrix
      # @param matrix [sparse matrix] used to mulitiply original matrix
      # @return [Sparse matrix] returns multiplied matrix
      # @example
      #   csr = Numo::Sparse::CSR.new(Numo::DFloat[[1, 0, 1], [1, 1, 1], [0, 0, 1]])
      #   csc = Numo::Sparse::CSC.new(Numo::DFloat[[2, 2, 0], [0, 0, 2], [0, 0, 0]])
      #   csr2 = csr.multiply(csc)
      #   # => data => [2, 2, 2, 2, 2], indices => [0, 1, 0, 1, 2], indptr => [0, 2, 5, 5]
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
