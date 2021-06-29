module pivotOperations
using LinearAlgebra
using .Threads

export pivotGauss, pivotSimple, pivotHybrid, pivotSimpleInbounds
export pivotSimpleParallel, pivotSimpleView, pivotSimpleView!
export pivotGaussNew, pivotGaussplainfor

"""
	pivotGauss(A, i, j)

Performs a pivot operation on `A` via multiplication by elementary matrices. See:
https://en.wikipedia.org/wiki/Elementary_matrix
"""
function pivotGauss(A, i, j)
    m, _ = size(A)

    # First we divide the pivot row by the pivot value so the pivot (A[i, j]) becomes a principal 1.
    # The idea is to perform every operation on the matrix as a matrix product.
    # d is a vector that will be used later to create a diagonal matrix.
    d = vec([ones(i - 1, 1); A[i, j] .^ -1; ones(m - i, 1)])
    D = Matrix(Diagonal(d))
    # The product D * A performs the division (yes I realize I could use ./)
    A = D * A

    # Getting the multiples such that R[:, j] - efes .* A[i, j] = 0
    efes = A[:, j]

    # Allocating an identity matrix that will be modified to become elementary.
    E = Matrix(1.0 * I(m)) # Hack to make it a numeric (not bool) matrix
    # Modifying E to make it elementary and perform the desired operation
    E[:, i] = -efes
    E[i, :] = -E[i, :] # Ugly. Corrects sign error so thet we don't get a -1

    # Returns the result of the product wich is the pivoted matrix
    return E * A
end


"""
    pivotHybrid(A, i, j)
Performs a pivot operation on `A` with a "hybrid" method. The principal 1 is created by simple
elementwise division and the rest of the pivoting operation (creating zeros above and below) is
acomplished with a matrix product by an elementary matrix.
"""
function pivotHybrid(A, i, j)
    m, _ = size(A)

    # Dividing the row to get the principal 1.
    A[i, :] = A[i, :] ./ A[i, j]

    # Getting the multiples such that R[:, j] - efes .* A[i, j] = 0
    efes = A[:, j]

    # Allocating an identity matrix that will be modified to become elementary.
    # BLACK MAGIC: Changing the line below from 1 to 1.0 results in DRAMATIC performance differences
    E = Matrix(1.0 * I(m)) # Hack para que sea matriz numerica no de bools.

    # Modifying E to make it elementary and perform the desired operation
    E[:, i] = -efes
    E[i, :] = -E[i, :] # Ugly. Corrects sign error so thet we don't get a -1

    # Returns the result of the product wich is the pivoted matrix
    return E * A
end

"""
	pivotSimple(A, i, j)
Performs a pivot operation on `A` using a simple approach: for loops.
"""
function pivotSimple(A, i, j)
    # Dividing the row to get the principal 1.
    A[i, :] = A[i, :] ./ A[i, j]

    for irow = 1:size(A, 1)
        if irow != i
            A[irow, :] = A[irow, :] .- A[i, :] .* A[irow, j]
        end
    end

    return A
end


function pivotSimpleView!(A, i, j)
    # Dividing the row to get the principal 1.
    A[i, :] .= @view(A[i, :]) ./ A[i, j]

    for irow = 1:size(A, 1)
        if irow != i
            A[irow, :] .= @view(A[irow, :]) .- @view(A[i, :]) .* A[irow, j]
        end
    end

    return A
end


function pivotSimpleView(A, i, j)
    # Dividing the row to get the principal 1.
    A[i, :] = @view(A[i, :]) ./ A[i, j]

    for irow = 1:size(A, 1)
        if irow != i
            A[irow, :] = @view(A[irow, :]) .- @view(A[i, :]) .* A[irow, j]
        end
    end

    return A
end

"""
	pivotSimpleInbounds(A, i, j)
Performs a pivot operation on `A` using a annotated for loops. Intented to test the perfomance gains
of using @inbounds
"""
function pivotSimpleInbounds(A, i, j)
    @inbounds A[i, :] = A[i, :] ./ A[i, j]

    @inbounds for irow = 1:size(A, 1)
        if irow != i
            @inbounds A[irow, :] = A[irow, :] .- A[i, :] .* A[irow, j]
        end
    end

    return A
end

"""
	pivotSimple(A, i, j)
Performs a pivot operation on `A` using for loops, @inbounds annotations, and multithreading.
"""
function pivotSimpleParallel(A, i, j)
    @inbounds A[i, :] = A[i, :] ./ A[i, j]

    @threads for irow = 1:size(A, 1)
        if irow != i
            @inbounds A[irow, :] = A[irow, :] .- A[i, :] .* A[irow, j]
        end
    end

    return A
end

function pivotGaussNew(A::Matrix{Float64}, i::Int, j::Int)
    m, _ = size(A)
    # First we divide the pivot row by the pivot value so the pivot (A[i, j]) becomes a principal 1.
    # The idea is to perform every operation on the matrix as a matrix product.
    # d is a vector that will be used later to create a diagonal matrix.
    d = vec([ones(i - 1, 1); A[i, j]^-1; ones(m - i, 1)])
    D = Matrix(Diagonal(d))
    # The product D * A performs the division (yes I realize I could use ./)
    A = D * A

    # Getting the multiples such that R[:, j] - efes .* A[i, j] = 0
    efes = @view A[:, j]

    # Allocating an identity matrix that will be modified to become elementary.
    E = Matrix{Float64}(I, m, m)
    # Modifying E to make it elementary and perform the desired operation
    E[:, i] = -efes
    E[i, :] = -E[i, :] # Ugly. Corrects sign error so thet we don't get a -1
    # Returns the result of the product wich is the pivoted matrix
    mul!(D, E, A)
    return D
end


function pivotPlainFor(A::Matrix{Float64}, i::Int, j::Int)
    n, m = size(A)
    M = copy(A)
    p = M[i, j]
    for l = 1:m
        M[i, l] = M[i, l] / p
    end
    for l = 1:m
        if l != j
            for k = 1:n
                if k != i
                    M[k, l] = M[k, l] - M[i, l] * M[k, j]
                end
            end
        end
    end
    for k = 1:n
        if k != i
            M[k, j] = 0.0
        end
    end
    return M
end

end
