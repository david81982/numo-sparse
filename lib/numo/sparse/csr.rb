require 'numo/sparse/base'

module Numo
  module Sparse
    class CSR < BaseTensor
      attr_reader :shape, :dtype, :data, :indptr, :indices, :indices_temp

#this is new
      def initialize(*args)
        if args.length == 4
          @data, @indices, @indptr, @shape = args
          @dtype = data.class
        else
          super
        end
      end

      def self.max_ndim
        2
      end

      def nnz
        @data.length
      end

      private def initialize_with_narray(narray)
        @shape = check_shape(narray.shape).dup.freeze
        @dtype = narray.class
        @data = narray[narray.ne(0)]
        make_csr(narray)
      end

      private def initialize_empty(shape, dtype)
        @shape = check_shape(shape).dup.freeze
        @dtype = check_dtype(dtype)
        @data = []
      end

#this is new
      # Creates the sparse matrix in csr format
      # @param narray [narray] the matrix that will be converted
      # @return [CSR] all values/array's assigned
      # @example
      #   narray = Numo::DFloat[[1, 0, 2], [0, 0, 3], [4, 5, 6]]
      #   csr = Numo::Sparse::CSR.new(narray)
      #   csr.indices
      #   # => [0, 2, 2, 0, 1, 2]
      private def make_csr(narray)
        row_limit, col_limit = shape[0], shape[1]
        matrix, curr_row, count = narray, 0, 0
        indices = []
        indices_temp = [] #this is for the transpose
        indptr = []
        indptr[0] = 0
        while curr_row < row_limit
          curr_col = 0
          while curr_col < col_limit
            if matrix[curr_row,curr_col] != 0
              count += 1
              indices.push(curr_col)
              indices_temp.push(curr_row)
            end
            curr_col += 1
          end
          indptr.push(count)
          curr_row += 1
        end
        @indices = Numo::Int32[*indices]
        @indices_temp = Numo::Int32[*indices_temp]
        @indptr = Numo::Int32[*indptr]
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
        CSR.new(data, indices_temp, indptr, shape)
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
        matrix = CSR.new(data, indices, indptr, shape).to_narray
        result = data.class.zeros([max_rows, 1])
        until curr_row == max_rows do
          if matrix[curr_row, col] != 0
            result[curr_row, 0] = matrix[curr_row, col]
          end
          curr_row += 1
        end
        CSR.new(result)
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
        matrix = CSR.new(data, indices, indptr, shape).to_narray
        result = data.class.zeros([1, max_col])
        until curr_col == max_col do
          if matrix[row, curr_col] != 0
            result[0, curr_col] = matrix[row, curr_col]
          end
          curr_col += 1
        end
        CSR.new(result)
      end

#this is new
      # Converts CSR matrix into CSC
      # @return [CSC] CSC sparse matrix
      # @example
      #   narray = Numo::DFloat[[1, 0, 2], [0, 0, 3], [4, 5, 6]]
      #   csr = Numo::Sparse::CSR.new(narray)
      #   csr.to_csc
      #   # => csr.class => CSC
      def to_csc()
        CSC.new(data, indices_temp, indptr, shape)
      end

#this is new
      # Multiplies matrix by scalar
      # @param scalar [scalar] amount that the matrix will be multiplied by
      # @return [CSR] creates the new multiplied csr matrix
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
        CSR.new(new_data, new_indices, new_indptr, new_shape)
      end

#this is new
      # Multiplies matrix by matrix
      # @param matrix [matrix] R
      # @return [CSR] R
      # @example
      #   E
      #   E
      #   E
      #   # =>
      def multiply(matrix)
        data1, indices1, indptr1, shape1= matrix.data, matrix.indices, matrix.indptr, matrix.shape
        if shape[1] == shape1[0]
          csr = self.class.new(data, indices, indptr, shape).to_narray
          csr1 = matrix.class.new(data1, indices1, indptr1, shape1).to_narray
          i, j, k, l, m, n, p = 0, 0, 0, 0, 0, 0, 0
          shape2 = [shape[0], shape1[1]]
          narray = data.class.zeros(shape2)
          until i == shape[0] do
            until j == shape1[1]do
              until l == shape1[0] do
                p += (csr[k, l] * csr1[m, n])
                l += 1
                m += 1
              end
              narray[i, j] = p
              j += 1
              n += 1
              p = 0
              l = 0
              m = 0
            end
            j = 0
            n = 0
            k += 1
            i += 1
          end
          CSR.new(narray)
        else
        p "Unable to perform matrix multiplication"
        end
      end
    end
  end
end
