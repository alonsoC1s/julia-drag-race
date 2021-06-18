function [Results] = benchmark(reps)
	Results = [];
	% Creando tabla para guardar resultados
	tsize = [0, 4],
	vtypes = ["string", "string", "double", "double"];
	vnames = ["lang", "metodo", "dim", "tiempo"]
	raw = table('Size', tsize,'VariableTypes', vtypes, 'VariableNames', vnames);

	for dim = 100:100:1500
		% Aqui crear A y su indice de acceso.
		% con rng(97) se seedea el MersenneTwister
		rng(98, "twister")
		% Fijando el rango
		b = -100;
		a = 100;
		% Matriz random en el rango con el seed deseado
		A = (b-a) .* rand(dim, dim) + a;
		% Poniendo el seed otra vez porque Matlab "resetea" el twister cada que se llama rand.
		rng(98, "twister")
		% Generando un indice aleatorio para accesar A.
		idx = randi([1, dim], 1, 2);

		% Corriendo pruebas
		% pivote Gauss
		for iter = 1:reps
			pivStart = tic;
			pivotGauss(A, idx(1), idx(2));
			pivTime = toc(pivStart);

			raw = [raw; {"Matlab", "pivotGauss", dim, pivTime}];
		end

		% pivote hibrido
		for iter = 1:reps
			pivStart = tic;
			pivotHybrid(A, idx(1), idx(2));
			pivTime = toc(pivStart);

			raw = [raw; {"Matlab", "pivotHybrid", dim, pivTime}];
		end

		% pivote simple
		for iter = 1:reps
			pivStart = tic;
			pivotSimple(A, idx(1), idx(2));
			pivTime = toc(pivStart);

			raw = [raw; {"Matlab", "pivotSimple", dim, pivTime}];
		end

	end
	% Guardando resultados
	writetable(raw, "benchmarks/matlab.csv")
end
