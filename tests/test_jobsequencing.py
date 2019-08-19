#   Copyright 2019 Joseph T. Iosue
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

"""
Contains tests for the JobSequencing class.
"""

from qubovert import JobSequencing
from qubovert.utils import solve_qubo_bruteforce, solve_ising_bruteforce
from numpy import allclose


job_lengths = {"job1": 2, "job2": 3, "job3": 1}
num_workers = 2
problem = JobSequencing(job_lengths, num_workers, log_trick=False)
problem_log = JobSequencing(job_lengths, num_workers)
Q, offset_Q = problem.to_qubo()
Q_log, offset_Q_log = problem_log.to_qubo()
h, J, offset_I = problem.to_ising()
h_log, J_log, offset_I_log = problem_log.to_ising()

solutions = ({'job1', 'job3'}, {'job2'}), ({'job2'}, {'job1', 'job3'})
obj_val = 3


def test_jobsequencing_str():

    assert eval(str(problem)) == problem
    assert eval(str(problem_log)) == problem_log


def test_jobsequencing_bruteforce():

    assert problem.solve_bruteforce() in solutions
    assert (
        problem.solve_bruteforce(all_solutions=True) in
        (list(solutions), list(reversed(solutions)))
    )


def test_jobsequencing_bruteforce_solve():

    assert problem.solve_bruteforce() in solutions
    assert problem.solve_bruteforce(True) in (
        list(solutions), [solutions[1], solutions[0]]
    )


# QUBO

def test_jobsequencing_qubo_logtrick_solve():

    e, sol = solve_qubo_bruteforce(Q_log, offset_Q_log)
    solution = problem_log.convert_solution(sol)
    assert problem_log.is_solution_valid(solution)
    assert solution in solutions
    assert allclose(e, obj_val)


def test_jobsequencing_qubo_solve():

    e, sol = solve_qubo_bruteforce(Q, offset_Q)
    solution = problem.convert_solution(sol)
    assert problem.is_solution_valid(solution)
    assert solution in solutions
    assert allclose(e, obj_val)


def test_jobsequencing_qubo_logtrick_numvars():

    assert (
        len(set(y for x in Q_log for y in x))
        ==
        problem_log.num_binary_variables
    )


def test_jobsequencing_qubo_numvars():

    Q_notlog, offset = problem.to_qubo()
    assert (
        len(set(y for x in Q_notlog for y in x))
        ==
        problem.num_binary_variables
    )


# ising

def test_jobsequencing_ising_logtrick_solve():

    e, sol = solve_ising_bruteforce(h_log, J_log, offset_I_log)
    solution = problem_log.convert_solution(sol)
    assert problem_log.is_solution_valid(solution)
    assert solution in solutions
    assert allclose(e, obj_val)


def test_jobsequencing_ising_solve():

    e, sol = solve_ising_bruteforce(h, J, offset_I)
    solution = problem.convert_solution(sol)
    assert problem.is_solution_valid(solution)
    assert solution in solutions
    assert allclose(e, obj_val)


def test_jobsequencing_ising_logtrick_numvars():

    assert (
        len(set(y for x in J_log for y in x).union(set(h_log.keys())))
        ==
        problem_log.num_binary_variables
    )


def test_jobsequencing_ising_numvars():

    assert (
        len(set(y for x in J for y in x).union(set(h.keys())))
        ==
        problem.num_binary_variables
    )