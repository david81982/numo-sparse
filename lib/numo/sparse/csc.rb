require 'numo/sparse/base'

module Numo
  module Sparse
    class CSC < BaseTensor
      attr_reader :shape, :dtype, :data, :indptr, :indices, :indices_temp

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

      def transpose()
        [data, indices_temp, indptr]
      end
      
      def get_col()
        indices_temp
      end
      
      def get_row()
        indices
      end
      
      def to_csr()
        [data, indices_temp, indptr]
      end
    end
  end
end
