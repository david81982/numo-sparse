require 'numo/sparse/base'

module Numo
  module Sparse
    class CSC < BaseTensor
      attr_reader :shape, :dtype, :data, :indptr, :indices

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
        to_narray()
        #transpose()
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
        indptr = []
        data = []
        indptr[0] = 0
        while curr_col < col_limit
          curr_row = 0
          while curr_row < row_limit
            if narray[curr_row, curr_col] != 0
              count += 1
              indices.push(curr_row)
              data.push(narray[curr_row, curr_col])
            end
            curr_row += 1
          end
          indptr.push(count)
          curr_col += 1
        end
        @data = narray.class[*data]
        @indices = Numo::Int32[*indices]
        @indptr = Numo::Int32[*indptr]
      end

      def to_narray()
        matrix = data.class.zeros(shape)
        col, current, curr_ind = 0, 0, 0
        curr_data, col_lim, curr_ptr = 0, 0, 1
        while col < (indptr.size - 1)
          col_lim = (indptr[curr_ptr] - indptr[curr_ptr-1])
          while current < col_lim
            matrix[indices[curr_ind],col] = data[curr_data]
            curr_ind += 1
            curr_data += 1
            current += 1
          end
          curr_ptr += 1
          col += 1
          current = 0
        end
        matrix
      end

      def transpose()
=begin
        trans = Numo::Sparse::CSR.new(self.to_narray)
        @data = Numo.class[trans.data]
        @indices = Numo::Int32[trans.indices]
        @indptr = Numo::Int32[trans.indptr]
        ###What if we just added the col in the original funct
        ###and we just store it for the transpose so all we have to 
        ###do is reassign indices
=end
      end

      def to_csc
        self
      end
    end
  end
end
