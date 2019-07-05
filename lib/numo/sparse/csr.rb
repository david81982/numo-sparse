require 'numo/sparse/base'

module Numo
  module Sparse
    class CSR < BaseTensor
      attr_reader :shape, :dtype, :data, :indptr, :indices, :blank, :results
	  
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
        #to_csr #####
		blank = narray.ne(0) #####
p blank
		@results = make_results(narray) #####
      end

      private def initialize_empty(shape, dtype)
        @shape = check_shape(shape).dup.freeze
        @dtype = check_dtype(dtype)
        @data = []
      end
      
      private def make_results(blank) #####
		#initialization
        i, j, matrix = shape[0], shape[1], blank
        a, count = 0, 0
        indices = []
        indptr = []
        indptr[0] = 0
p blank
        #start of the code itself
        while a < i
		  b = 0
		  
          while b < j
            if (matrix[a,b] != 0)
              count += 1
              indices.push(b)
            end
			b += 1
          end
		  
          indptr.push(count) 
		  a += 1		  
        end
p count
p data
p indices
p indptr
		[data, indices, indptr]
      end
      
      
      #begin This is a draft for converting a csr matrix back to normal
      #private def to_regular_matrix()
        #t, a, c, d, tempor, i = 0, 0, 0, 0, 0, 1	
        
        #while t < (indptr.length() - 1)	 Create a limit for the rows
          #tempor = (indptr[i] - indptr[i-1] 	number of non-zero values in the row
          #while a < tempor 	#assign the data to their positions
              #matrix[t][indices[c]] = data[d] 	find the correct position and input the correct values
              #TODO: correct the matrix[]
              #c += 1
              #d += 1
              #a += 1
          #end
          #i += 1
          #t += 1
		  #a = 0
      #end
    #end
      
    end
  end
end
