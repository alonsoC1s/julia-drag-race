import numpy as np


def pivotGauss(A, i, j):
    m, _ = A.shape

    # Dividing the i-th row by A[i, j] to create a principal 1.
    d = np.hstack([np.ones(i), float(A[i, j]) ** -1, np.ones(m - i - 1)])
    D = np.diag(d)

    # Matrix product carries out the division
    A = np.dot(D, A)

    # Storing the factors such that multiplied by A[i, :] and then substracted, the result is zero.
    efes = A[:, j]

    # Creating an identity matrix that later on becomes an elementary matrix
    E = np.eye(m)

    # Setting the factors for each row
    E[:, i] = -efes
    # Fixes the sign error so that the principal 1 is not negative.
    E[i, :] = -E[i, :]

    return np.dot(E, A)


def pivotHybrid(A, i, j):
    m, _ = A.shape

    # Dividing the i-th row to create the principal 1.
    A[i, :] = A[i, :] / A[i, j]

    # Storing the factors such that multiplied by A[i, :] and then substracted, the result is zero.
    efes = A[:, j]

    # Creating an identity matrix that later on becomes an elementary matrix
    E = np.eye(m)

    # Setting the factors for each row
    E[:, i] = -efes
    # Fixes the sign error so that the principal 1 is not negative.
    E[i, :] = -E[i, :]

    return np.dot(E, A)


def pivotSimple(A, i, j):
    m, _ = A.shape

    # Dividing the i-th row to create the principal 1.
    A[i, :] = A[i, :] / A[i, j]

    for irow in range(m):
        if irow != i:
            A[irow, :] = A[irow, :] - A[i, :] * A[irow, j]

    return A
