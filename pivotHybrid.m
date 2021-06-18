function B = pivotHybrid(A, i, j)
	[m, n] = size(A);

	A(i,:) = A(i,:) / A(i,j);

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
