require 'numo/sparse/base'

module Numo
  module Sparse
    class CSR < BaseTensor
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
        csrmask = narray.ne(0)
		@csrds = make_csrd(mask)
      end

      private def initialize_empty(shape, dtype)
        @shape = check_shape(shape).dup.freeze
        @dtype = check_dtype(dtype)
        @data = []
      end
	  
	  #draft of the conversion of regular matrix to csr
	  private def to_csr(shape, data)
		#initialization
		I, J, matrix = shape[i], shape[j], data
		A, B = 0, 0
		data = []
		indptr = []
		count = []
		count.at[I] = 0
		I += 1
		
		#start of the code itself
		while A < 2
			while B < 2
				if (matrix.at[i][j] != 0)
					count += 1
					data.push=(matrix.at[I][J])
					indices.push(J)
				end
			end
			indptr.push(count) 
		end
	  
	  
	  =begin #This is a draft for converting a csr matrix back to normal
	  private def to_regular_matrix()
		t, a, c, d, tempor, i = 0, 0, 0, 0, 0, 1	#initialization
		
		while t < (indptr.length() - 1)	 #Create a limit for the rows
			tempor = (indptr.at[i] - indptr.at[i-1] 	#number of non-zero values in the row
			while a < tempor 	#assign the data to their positions
				matrix.at[t][indices.at[c]] = data.at[d] 	#find the correct position and input the correct values
				TODO: correct the matrix.at[]
				c += 1
				d += 1
				a += 1
			end
			i += 1
			t += 1
			a = 0
		end
	  end
	  =end
	  
    end
  end
end
