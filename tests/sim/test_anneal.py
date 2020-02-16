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

"""
Contains tests for the simulated annealing in the ``qubovert.sim`` library.
"""

from qubovert.sim import anneal_qubo, anneal_quso, anneal_pubo, anneal_puso
from numpy.testing import assert_raises


def test_anneal_qubo():

    with assert_raises(NotImplementedError):
        anneal_qubo()


def test_anneal_quso():

    with assert_raises(NotImplementedError):
        anneal_quso()


def test_anneal_pubo():

    with assert_raises(NotImplementedError):
        anneal_pubo()


def test_anneal_puso():

    with assert_raises(NotImplementedError):
        anneal_quso()