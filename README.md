Simple benchmarks with basic linear algebra routines to compare
Julia's performance to Matlab's and Python's. The benchmarks are based
on a "pivot operation". Which is a single step of the [Gaussian
elimination](https://en.wikipedia.org/wiki/Gaussian_elimination)
algorithm to reduce a matrix to it's RREF (Reduced row echelon
form). This step is referred to as a "pivoting operation", and
consists of taking the ij-th entry of A (`A[i, j]`), and applying the
elementary operations to:

1. Make `A[i, j]` equal to 1.
2. Make the remaining entries on the column (`A[1, j], ... , A[i-1,
   j], A[i+1, j], ..., A[end, j]` equal to 0.

The elementary row operations described by the algorithm are carried
out essentially by one of two methods:

1. "Manually" performing the elementary operation of adding a multiple
   of one row to another to create zeros above or below the pivot
   entry.

2. Constructing an [elementary
   matrix](https://en.wikipedia.org/wiki/Elementary_matrix) that
   "encodes" the row operations, and compute the product `E * A` to
   carry out the pivoting.

Implementations for the methods described above can be found in
`pivotOperations.jl` for Julia, `pivot_operations.py` for python, and
the individual Matlab scripts (i.e `pivotGauss.m`).

The basic benchmark consists of the Gaussian Pivoting (method 2
described above), Simple Pivoting (method 1 described above), and a
"hybrid" pivoting strategy, which is basically an enhanced Gaussian to
allocate less memory. Additionally, for the Julia tests some other
enhancements for the simple pivoting were introduced to try and take
advantage of some Julia-specific optimizations. Their names start with
`pivotSimple` and a name to identify the optimization (i.e
`pivotSimpleInbounds`).

Finally, the code that actually runs the benchmarks is a separate
script for each language. Julia has a implementation using
BenchmarkTools and another with a naive approach to timing. The file
`benchmarks/deathmatch.py` creates graphs and visualizations.
