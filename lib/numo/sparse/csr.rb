require 'numo/sparse/base'

module Numo
  module Sparse
    class CSR < BaseTensor
      attr_reader :shape, :dtype, :data, :indptr, :indices, :coords, :matrix
      
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
        @coords = make_coords(narray) #####
        @matrix = to_matrix(narray)
      end

      private def initialize_empty(shape, dtype)
        @shape = check_shape(shape).dup.freeze
        @dtype = check_dtype(dtype)
        @data = []
      end
      
      private def make_coords(narray)
        row_limit, col_limit, matrix, curr_row, count = 
        shape[0], shape[1], narray, 0, 0
        indices = []
        indptr = []
        indptr[0] = 0
        while curr_row < row_limit
          curr_col = 0
          while curr_col < col_limit
            if (matrix[curr_row,curr_col] != 0)
              count += 1
              indices.push(curr_col)
            end
            curr_col += 1
          end
          indptr.push(count) 
          curr_row += 1
        end
        [data, indices, indptr]
      end
      
      private def to_matrix(coords)
        matrix = Numo::DFloat.zeros(shape)
     
        data, indices, indptr = 
        coords[0], coords[1], coords[2]
        
        t, a, c, d, tempor, i = 
        0, 0, 0, 0, 0, 1

        while t < (indptr.size - 1)
          tempor = (indptr[i] - indptr[i-1])
          while a < tempor
              matrix[t][indices[c]] = data[d]
              c += 1
              d += 1
              a += 1
          end
          i += 1
          t += 1
          a = 0
        end
      [matrix]
      end
    end
  end
end
