include("pivotOperations.jl")

using .pivotOperations, Random, DataFrames, CSV

# Creating DataFrame to store results
function benchmarkNaive(reps)
    raw = DataFrame(lang = String[], method = String[], dim = Int[], time = Float64[])

    allFunctions = [
        pivotGauss,
        pivotSimple,
        pivotHybrid,
        pivotSimpleInbounds,
        pivotSimpleParallel,
        pivotSimpleView,
        pivotSimpleView!,
        pivotGaussNew,
        pivotGaussplainfor,
    ]

    @inbounds for dim = 100:100:1500

        @inbounds for pivFunc in allFunctions

            # Seed a MersenneTwister to generate a random matrix of specified dimensions
            A = rand(MersenneTwister(98), float(collect(-100:100)), (dim, dim))

            # Use the same Twister to generate a random index to the matrix
            idx = rand(MersenneTwister(98), 1:dim, 2)

            # Actual benchmarking
            @inbounds for iter = 1:reps
                # I am using @elepsed instead of @belapsed deliberately
                pivTime = @elapsed pivFunc(A, idx...)
                println("dim:$dim, $(string(pivFunc)) rep:$iter en $pivTime s")

                push!(raw, ["Julia", string(pivFunc), dim, pivTime])
            end
        end

    end

    @info "Writing results to benchmarks/julia_dumb.csv"
    CSV.write("benchmarks/julia_dumb.csv", raw)
end
