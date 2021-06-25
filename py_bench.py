import pandas as pd
import numpy as np
import pivot_operations as po
from time import process_time


# List of dicts to create dataframe later on
def benchmark(reps):
    observations = []

    # List of all available pivot methods
    all_functions = [po.pivotGauss, po.pivotHybrid, po.pivotSimple]

    # Seeding the Mersenne twister for numpy rand

    for dim in np.arange(100, 1500, 100):
        for piv_func in all_functions:
            # Generating A with a seeded Mersenne twister
            A = np.random.randint(-100, 100, (dim, dim))
            # Generating a random index for A
            idx = np.random.randint(0, dim - 1, 2)

            # Benchmarking process
            for itr in range(1, reps):
                start_time = process_time()
                A = piv_func(A, idx[0], idx[1])
                pivTime = process_time() - start_time
                print(f"dim:{dim}, {piv_func.__name__} rep:{itr} en {pivTime} s")

                observations.append(
                    {
                        "lang": "python",
                        "method": piv_func.__name__,
                        "dim": dim,
                        "time": pivTime,
                    }
                )

    raw = pd.DataFrame(observations)

    raw.to_csv("benchmarks/python.csv")
