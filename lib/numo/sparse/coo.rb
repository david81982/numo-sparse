require 'numo/sparse/base'

module Numo
  module Sparse
    class COO < BaseTensor
      attr_reader :shape, :dtype, :data, :coords

      def nnz
        @data.length
      end

      private def initialize_with_narray(narray)
        @shape = check_shape(narray.shape).dup.freeze
        @dtype = narray.class
        mask = narray.ne(0)
        @data = narray[mask]
        @coords = make_coords(mask)
      end

      private def initialize_empty(shape, dtype)
        @shape = check_shape(shape).dup.freeze
        @dtype = check_dtype(dtype)
        @data = []
      end

      private def make_coords(mask)
        ndim = self.ndim
        coords = Array.new(ndim) { Array.new }
        cursor = Array.new(ndim, 0)
        i, n = 0, mask.size
        while true
          if mask[i] == 1
            j = 0
            while j < ndim
              coords[j] << cursor[j]
              j += 1
            end
          end

          i += 1
          break if i == n

          j = -1
          cursor[j] += 1
          while cursor[j] == shape[j]
            cursor[j] = 0
            j -= 1
            break if j < -ndim
            cursor[j] += 1
          end
        end
        coords
      end

      def to_narray() #This is only with 2D
        matrix = data.class.zeros(shape)
          count, curr_data, curr_col, curr_row = 0, 0, 0, 0
          row, columb = coords[0], coords[1]
          while count < data.size
            matrix[row[curr_row], columb[curr_col]] = data[curr_data]
            count += 1
            curr_data += 1
            curr_row += 1
            curr_col += 1
          end
        matrix
      end

      def transpose() #This might work for more than 3D
        temp = []
        i = ndim
        if i > 1
          temp = self.coords[i-2]
          self.coords[i-2] = self.coords[i-1]
          self.coords[i-1] = temp
        end
        [coords[0], coords[1], coords[2]]
      end
    end
  end
end
