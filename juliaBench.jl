"""
Pruebas de desempeño para operaciones de pivoteo implementadas
"""

include("pivotOperations.jl")

using .pivotOperations, BenchmarkTools, Random, DataFrames, CSV

# Parent testing suite
suite = BenchmarkGroup()

# Creating a suite to store the results
suite["pivoteo"] = BenchmarkGroup()

@info "Generando tests suites"
# Genrating random data of different dimensions
for dim = 100:100:1500
	A = rand(MersenneTwister(98), float(collect(-100:100)), (dim, dim))
	idx = rand(MersenneTwister(98), 1:dim, 2)

	# Añadimos al suite una prueba por cada función
	for func in (pivotGauss, pivotHybrid, pivotSimple)
		# Generando función. Paso index sin splootear por facilidad
		suite["pivoteo"][string(func), dim] = @benchmarkable $(func)($A, $idx[1], $idx[2]) evals=1 samples=7
	end
end

# Storing params for reproducibility
paramspath = "benchmark_params_jl.json"

@info "Loading or generating testing params"
if isfile(paramspath)
	@debug "Params found. Loading"
	loadparams!(suite, BenchmarkTools.load(paramspath)[1], :evals, :samples)
else
	@debug "No params found. Generating params"
	tune!(suite)
	BenchmarkTools.save(paramspath, params(suite))
end

# Running the suite
@info "Running testing suite"
results = run(suite, verbose=true)

# Storing results in a DataFrame
raw = DataFrame(lang = String[],
	method = String[],
	dim = Int[],
	time = Float64[])

# Storing on DataFrame. Probably inneficient
@info "Filling up the Dataframe"
for (tag, trial) in results["pivoteo"]
	alg, dim = tag
	times = trial.times
	for t in times
		push!(raw, ["Julia", alg, dim, t])
	end
end

# Storing the results in csv
@info "Writing results to benchmarks/julia.csv"
CSV.write("benchmarks/julia.csv", raw)
