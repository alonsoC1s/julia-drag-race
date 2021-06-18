function A = pivotSimple(A, i, j)
	pivval = A(i,j);

	A(i,:) = A(i,:) / pivval;

	for irow = 1:size(A,1)
		if irow ~= i
			A(irow, :) = A(irow, :) - A(i, :) * A(irow, j);
		end
	end
end
