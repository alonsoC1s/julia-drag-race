function [Results] = benchmark(reps)
	Results = [];
	% Creando tabla para guardar resultados
	tsize = [0, 4],
	vtypes = ["string", "string", "double", "double"];
	vnames = ["lang", "method", "dim", "time"]
	raw = table('Size', tsize,'VariableTypes', vtypes, 'VariableNames', vnames);

	for dim = 100:100:1500
		% Creating the matrix A and its random index
		% Seeding the Mersenne Twister so the randomly generated A is the same as in Julia
		rng(98, "twister")
		% Setting a range (a, b)
		b = -100;
		a = 100;
		% Random matrix with specified range and seed
		A = (b-a) .* rand(dim, dim) + a;
		% Re-seeding the generator because Matlab resets it after calling rand
		rng(98, "twister")
		% Generating a random index to access.
		idx = randi([1, dim], 1, 2);

		% Running the tests
		% Gaussian pivoting
		for iter = 1:reps
			pivStart = tic;
			pivotGauss(A, idx(1), idx(2));
			pivTime = toc(pivStart);

			raw = [raw; {"Matlab", "pivotGauss", dim, pivTime}];
		end

		% Hybrid pivoting
		for iter = 1:reps
			pivStart = tic;
			pivotHybrid(A, idx(1), idx(2));
			pivTime = toc(pivStart);

			raw = [raw; {"Matlab", "pivotHybrid", dim, pivTime}];
		end

		% Simple pivoting
		for iter = 1:reps
			pivStart = tic;
			pivotSimple(A, idx(1), idx(2));
			pivTime = toc(pivStart);

			raw = [raw; {"Matlab", "pivotSimple", dim, pivTime}];
		end

	end
	% Storing results in a csv
	writetable(raw, "benchmarks/matlab.csv")
end
