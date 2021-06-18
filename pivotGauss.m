function B = pivotGauss(A, i, j)
	[m, n] = size(A);

	% Dividing the ith row by A(i,j) to get the principal 1. Operation performed via matrix product.
	A = diag([ones(1,i-1), A(i,j)^-1, ones(1,m-i)]) * A;

	% Getting the multiples such that R[:, j] - efes .* A[i, j] = 0
	efes = A(:,j);

	% Allocating an identity matrix that will be modified to become elementary.
	E = eye(m,m);

	% Modifying the matrix so it becomes elementary
	E(:,i) = -efes;
	E(i,:) = -E(i,:); % Ugly. Corrects sign error so thet we don't get a -1

	% Premultiplying to perform elementary row operations
	B = E * A;
end
