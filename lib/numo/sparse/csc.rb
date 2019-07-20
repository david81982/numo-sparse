require 'numo/sparse/base'

module Numo
  module Sparse
    class CSC < BaseTensor
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
        make_csc(narray)
      end

      private def initialize_empty(shape, dtype)
        @shape = check_shape(shape).dup.freeze
        @dtype = check_dtype(dtype)
        @data = []
      end

    # Creates the sparse matrix in csc format
    # @param narray [narray] the matrix that will be converted
    # @return [array] the converted matrix in csc format
    # @example
    #   narray = Numo::DFloat[[1, 0, 4], [0, 0, 5], [2, 3, 6]]
    #   csc = Numo::Sparse::CSC.new(naray)
    #   csc.indices
    #   # => [0, 2, 2, 0, 1, 2]
      private def make_csc(narray)
        row_limit, col_limit = shape[0], shape[1]
        curr_col, count = 0, 0
        indices = []
        indices_temp = [] #this is for the transpose
        indptr = []
        data = []
        indptr[0] = 0
        while curr_col < col_limit
          curr_row = 0
          while curr_row < row_limit
            if narray[curr_row, curr_col] != 0
              count += 1
              indices.push(curr_row)
              indices_temp.push(curr_col)
              data.push(narray[curr_row, curr_col])
            end
            curr_row += 1
          end
          indptr.push(count)
          curr_col += 1
        end
        @data = narray.class[*data]
        @indices = Numo::Int32[*indices]
        @indices_temp = Numo::Int32[*indices_temp]
        @indptr = Numo::Int32[*indptr]
      end


#this is new
      # Converts the sparse matrix into a normal array
      # @return [matrix] the matrix from CSC
      # @example
      #   narray = Numo::DFloat[[1, 0, 4], [0, 0, 5], [2, 3, 6]]
      #   csc = Numo::Sparse::CSC.new(narray)
      #   csc.to_narray
      #   # => Numo::DFloat[[1, 0, 4], [0, 0, 5], [2, 3, 6]]
      def to_narray()
        narray = data.class.zeros(shape)
        col, current, curr_ind = 0, 0, 0
        curr_data, col_lim, curr_ptr = 0, 0, 1
        while col < (indptr.size - 1)
          col_lim = (indptr[curr_ptr] - indptr[curr_ptr-1])
          while current < col_lim
            narray[indices[curr_ind],col] = data[curr_data]
            curr_ind += 1
            curr_data += 1
            current += 1
          end
          curr_ptr += 1
          col += 1
          current = 0
        end
        narray
      end

=begin
#this is new
      # Returns the transpose of the CSC matrix
      # @return [CSC] transposed matrix in CSC format
      # @example
      #   narray = Numo::DFloat[[1, 0, 4], [0, 0, 5], [2, 3, 6]]
      #   csc = Numo::Sparse::CSC.new(narray)
      #   csc.transpose
      #   # => indices => Numo::Int32[0, 0, 1, 2, 2, 2]
      def transpose()
        CSC.new(data, indices_temp, indptr, shape)
      end

#this is new
      # Returns the column of the CSC matrix
      # @param col [scalar] Which column will be returned
      # @return [CSC] Column of the matrix in CSC format
      # @example
      #   narray = Numo::DFloat[[1, 0, 4], [0, 0, 5], [2, 3, 6]]
      #   csc = Numo::Sparse::CSC.new(narray)
      #   csc.get_col(1)
      #   # => data => [3], indices => [2], indptr => [0, 1]
      def get_col(col)
        max_rows, curr_row, col = shape[0], 0, col
        matrix = CSC.new(data, indices, indptr, shape).to_narray
        result = data.class.zeros([max_rows, 1])
        until curr_row == max_rows do
          if matrix[curr_row, col] != 0
            result[curr_row, 0] = matrix[curr_row, col]
          end
          curr_row += 1
        end
        CSC.new(result)
      end

#this is new
      # Returns the row of the CSC matrix
      # @param row [scalar] Which row will be returned
      # @return [CSC] Row of the matrix in CSC format
      # @example
      #   narray = Numo::DFloat[[1, 0, 4], [0, 0, 5], [2, 3, 6]]
      #   csc = Numo::Sparse::CSC.new(narray)
      #   csc.get_row(1)
      #   # => data => [5], indices => [0], indptr => [0, 0, 0, 1]
      def get_row(row)
        max_col, curr_col, row = shape[1], 0, row
        matrix = CSC.new(data, indices, indptr, shape).to_narray
        result = data.class.zeros([1, max_col])
        until curr_col == max_col do
          if matrix[row, curr_col] != 0
            result[0, curr_col] = matrix[row, curr_col]
          end
          curr_col += 1
        end
        CSC.new(result)
      end
=end

#this is new
      # Converts CSC matrix into CSR
      # @return [CSC] CSR sparse matrix
      # @example
      #   narray = Numo::DFloat[[1, 0, 4], [0, 0, 5], [2, 3, 6]]
      #   csc = Numo::Sparse::CSC.new(narray)
      #   csc.to_csr
      #   # => csc.class => CSR
      def to_csr()
        CSR.new(data, indices_temp, indptr, shape)
      end

=begin
#this is new
      # Multiplies matrix by scalar
      # @param scalar [scalar] amount that the matrix will be multiplied by
      # @return [CSC] creates the new multiplied csc matrix
      # @example 
      #   narray = Numo::DFloat[[1, 0, 2], [0, 0, 3], [4, 5, 6]]
      #   csc = Numo::Sparse::CSC.new(narray)
      #   csc * 2
      #   # => data = [2, 4, 6, 8, 10, 12]
      def *(scalar)
        new_data = data * scalar
        new_indices = indices.dup
        new_indptr = indptr.dup
        new_shape = shape.dup
        CSC.new(new_data, new_indices, new_indptr, new_shape)
      end
=end
    end
  end
end
