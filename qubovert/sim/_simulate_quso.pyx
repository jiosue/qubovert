# distutils: language=c
# cython: language_level=3
#   Copyright 2020 Joseph T. Iosue
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

cimport cython
from libc.stdlib cimport malloc, free


cdef extern from "simulate_quso.h":
    void simulate_quso(
        int len_state, int *state, double *h,
        int *num_neighbors, int *neighbors, double *J,
        int len_Ts, double *Ts, int *num_updates,
        int seed
    ) nogil


def c_simulate_quso(len_state, state, h, num_neighbors,
                    neighbors, J, len_Ts, Ts, num_updates, seed):
    """
    Simulate a QUSO with the C source.

    Parameters
    ----------
    len_state : int.
        The length of `state`, ie the number of spin.
    state: list of ints.
        `state[i]` is the value of the ith spin, either 1 or -1.
    h : list of floats.
        `h[i]` is the field value on spin `i`.
    num_neighbors : list of ints. 
        `num_neighbors[i]` is the number of neighbors that spin i has.
    neighbors : list of ints.
        ``neighbors[i]`` is the jth neighbor of spin ``k``, where 
        ``j = i - num_neighbors[k-1] - num_neighbors[k-2] - ...``
    J : list of doubles.
        ``J[i]`` is the coupling value between spin ``k`` and 
        ``neighbors[i]``.
    len_Ts : int.
        length of `Ts` and the length of `num_updates`.
    Ts : list of doubles.
        `Ts[j]` is the jth temperature to simulate the QUSO at.
    num_updates : list of ints. 
        `num_updates[j]` is the number of
        times steps to simulate the QUSO at temperature `Ts[j]`.
    seed : int. 
        seeds the random number generator (we use `rand` from the C standard
        library). If `seed` is a negative integer, then we seed the random
        number generator with `srand(time(NULL))`. If `seed` is a nonnegative
        integer, then we seed the random number generator with
        `srand((unsigned int)seed)`.

    Returns
    -------
    new_state : list of ints.

    Example
    -------
    `neighbors` and `J` are basically flattened arrays.
    In other words, we flatten the arrays `temp_neighbors` and
    `temp_J`, where `temp_neighbors` points to an array where `temp_neighbors[i][j]`
    is the jth neighbor of spin i, for j=0,...,num_neighbors[i]-1, and similarly,
    `temp_J` points to an array where `temp_J[i][j]` is the coupling value between
    spin i and spin `neighbors[i][j]`, for j=0,...,num_neighbors[i]-1.

    A spin model such as
        -z_0 z_1 + 2*z_1*z_2 + z_0
    must be represented as
        `h = {1., 0, 0}`
        `num_neighbors = {1, 2, 1}`
        `temp_neighbors = {{1}, {0, 2}, {1}}`
        `temp_J = {{-1.},
              {-1, 2},
              {2}}`
        `neighbors = {1, 0, 2, 1}`
        `J = {-1.,
              -1, 2,
              2}`
    """
    # convert all Python types to C
    cdef int c_len_state = len_state
    cdef int *c_state
    cdef double *c_h
    cdef int *c_num_neighbors
    cdef int *c_neighbors
    cdef double *c_J
    cdef int c_len_Ts = len_Ts
    cdef double *c_Ts
    cdef int *c_num_updates
    cdef int c_seed = seed

    c_state = <int *>malloc(len_state * cython.sizeof(int))
    c_h = <double *>malloc(len_state * cython.sizeof(double))
    c_num_neighbors = <int *>malloc(len_state * cython.sizeof(int))
    c_neighbors = <int *>malloc(len(neighbors) * cython.sizeof(int))
    c_J = <double *>malloc(len(J) * cython.sizeof(double))
    c_Ts = <double *>malloc(len(Ts) * cython.sizeof(double))
    c_num_updates = <int *>malloc(len(Ts) * cython.sizeof(int))

    for i in range(len_state):
        c_state[i] = state[i]
        c_h[i] = h[i]
        c_num_neighbors[i] = num_neighbors[i]
    for i in range(len(J)):
        c_neighbors[i] = neighbors[i]
        c_J[i] = J[i]
    for i in range(len_Ts):
        c_Ts[i] = Ts[i]
        c_num_updates[i] = num_updates[i]

    with nogil:
        simulate_quso(
            c_len_state, c_state, c_h,
            c_num_neighbors, c_neighbors, c_J,
            c_len_Ts, c_Ts, c_num_updates,
            c_seed
        )

    final_state = [c_state[i] for i in range(len_state)]
    free(c_state)
    free(c_h)
    free(c_num_neighbors)
    free(c_neighbors)
    free(c_J)
    free(c_Ts)
    free(c_num_updates)
    return final_state
