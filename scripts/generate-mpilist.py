#!/bin/python3

import sys

if __name__ == "__main__":
    #print(sys.argv)
    if len(sys.argv) != 3:
        print("Arguments error.")
        print("Usage:")
        print("{} <number of MPI ranks> <lattice volume x.y.z.t>".format(sys.argv[0]))
        sys.exit(1)

    M = int(sys.argv[1])
    GRID = sys.argv[2]

    #print(M, GRID)

    # split Grid into dimensions
    g = []
    for i in GRID.split('.'):
        g.append(int(i))

    #print(g)

    x = 1
    y = 1
    z = 1
    t = 1

    while (t <= z and t <= int(g[3])):
        z = 1
        while (z <= y and z <= int(g[2])):
            y = 1
            while (y <= x and y <= int(g[1])):
                x = 1
                while (x <= M and x <= int(g[0])):
                    #print("{}.{}.{}.{}".format(x, y, z, t))

                    if (x * y * z * t == M):
                        if (x >= y >= z >= t):
                            # must have multiple of 4 points per dimension
                            p = True
                            if ((int(g[0] / x) % 4) != 0): p = False
                            if ((int(g[1] / y) % 4) != 0): p = False
                            if ((int(g[2] / z) % 4) != 0): p = False
                            if ((int(g[3] / t) % 4) != 0): p = False
                            if p == True:
                                print("{}.{}.{}.{}".format(x, y, z, t), end = '   ')
                    x = x * 2
                y = y * 2
            z = z * 2
        t = t * 2

    print("")
