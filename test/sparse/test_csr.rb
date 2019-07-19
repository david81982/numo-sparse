class TestSparseCSR < Test::Unit::TestCase
  sub_test_case(".new") do
    sub_test_case("with shape and dtype class") do
      test("normal case") do
        csr = Numo::Sparse::CSR.new([2, 3], Numo::DFloat)

        assert_equal([2, 3],
                     csr.shape)
        assert_equal(2,
                     csr.ndim)
        assert_equal(0,
                     csr.nnz)
      end

      test("with invalid shape") do
        assert_raise_kind_of(ArgumentError) do
          Numo::Sparse::CSR.new([2, 3, 4], Numo::DFloat)
        end
      end

      test("with invalid dtype") do
        assert_raise_kind_of(ArgumentError) do
          Numo::Sparse::CSR.new([2, 3], String)
        end
      end
    end

    sub_test_case("with Numo::NArray object") do
      test("with 2D array") do
        nary = Numo::DFloat[[1, 0, 2], [0, 3, 0], [4, 0, 5]]
        csr = Numo::Sparse::CSR.new(nary)

        assert_equal([3, 3],
                     csr.shape)
        assert_equal(2,
                     csr.ndim)
        assert_equal(5,
                     csr.nnz)
      end
    end

    sub_test_case("with Numo::NArray object") do
      test("create data/indices/indptr") do
        naray = Numo::DFloat[[1, 0, 2], [0, 0, 3], [4, 5, 6]]
        csr = Numo::Sparse::CSR.new(naray)
            
        assert_equal([3, 3],
                     csr.shape)
        assert_equal(2,
                     csr.ndim)
        assert_equal(6,
                     csr.nnz)
        assert_equal(Numo::DFloat[1, 2, 3, 4, 5, 6],
                     csr.data)
        assert_equal(Numo::Int32[0, 2, 2, 0, 1, 2],
                     csr.indices)
        assert_equal(Numo::Int32[0, 2, 3, 6],
                     csr.indptr)
      end
    end

#this is new
    sub_test_case("with Numo::NArray object") do
        test("conversion from csr to narray") do
          naray = Numo::DFloat[[1, 0, 2], [0, 0, 3], [4, 5, 6]]
          csr = Numo::Sparse::CSR.new(naray)
          assert_equal(naray,
                     csr.to_narray)
      end
    end

#this is new
    sub_test_case("with Numo::NArray object") do
        test("transpose of csr") do
          narray = Numo::DFloat[[1, 0, 2], [0, 0, 3], [4, 5, 6]]
          csr = Numo::Sparse::CSR.new(narray).transpose

          assert_equal(Numo::DFloat[1, 2, 3, 4, 5, 6],
                     csr.data)
          assert_equal(Numo::Int32[0, 0, 1, 2, 2, 2],
                     csr.indices)
          assert_equal(Numo::Int32[0, 2, 3, 6],
                     csr.indptr)
      end
    end

#this is new
    sub_test_case("with Numo::NArray object") do
        test("get col of csr") do
          narray = Numo::DFloat[[1, 0, 2], [0, 0, 3], [4, 5, 6]]
          csr = Numo::Sparse::CSR.new(narray).get_col(1)
          assert_equal(Numo::DFloat[5],
                     csr.data)
          assert_equal(Numo::Int32[0],
                     csr.indices)
          assert_equal(Numo::Int32[0, 0, 0, 1],
                     csr.indptr)
      end
    end

#this is new
    sub_test_case("with Numo::NArray object") do
        test("get row of csr") do
          narray = Numo::DFloat[[1, 0, 2], [0, 0, 3], [4, 5, 6]]
          csr = Numo::Sparse::CSR.new(narray).get_row(1)
          assert_equal(Numo::DFloat[3],
                     csr.data)
          assert_equal(Numo::Int32[2],
                     csr.indices)
          assert_equal(Numo::Int32[0, 1],
                     csr.indptr)
      end
    end

#this is new
    sub_test_case("with Numo::NArray object") do
        test("CSR to CSC") do
          narray = Numo::DFloat[[1, 0, 2], [0, 0, 3], [4, 5, 6]]
          csr = Numo::Sparse::CSR.new(narray).to_csc
          
          assert_equal(Numo::DFloat[1, 2, 3, 4, 5, 6],
                     csr.data)
          assert_equal(Numo::Int32[0, 0, 1, 2, 2, 2],
                     csr.indices)
          assert_equal(Numo::Int32[0, 2, 3, 6],
                     csr.indptr)
      end
    end

#this is new
    sub_test_case("with Numo::NArray object") do
      test("scalar multiplication") do
        narray = Numo::DFloat[[1, 0, 2], [0, 0, 3], [4, 5, 6]]
        csr = (Numo::Sparse::CSR.new(narray)) * 2
        assert_equal(Numo::DFloat[2, 4, 6, 8, 10, 12],
                     csr.data)
      end
    end
  end
end
