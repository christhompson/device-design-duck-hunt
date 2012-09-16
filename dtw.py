#
# DTW Functions
#


def d(a, b):
    """Cost function for two signals."""
    return abs(a - b)


def DTWDistance(s, t):
    """Compute the DTW of two series."""
    # Initialize an n by m "matrix"
    DTW = []
    n = len(s)
    m = len(t)
    for i in range(n):
        DTW.append([])
        for j in range(m):
            DTW[i].append(0)
    for i in range(m):
        DTW[0][i] = float("inf")
    for i in range(n):
        DTW[i][0] = float("inf")

    # Compute cost of the optimal DTW path
    DTW[0][0] = 0
    for i in range(n):
        for j in range(m):
            cost = d(s[i], t[j])
            DTW[i][j] = cost + min(DTW[i - 1, j],
                                  DTW[i, j - 1],
                                  DTW[i - 1, j - 1])
    return DTW[n - 1][m - 1]
