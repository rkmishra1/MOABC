# MOEAD-ABC: Multi-Objective Artificial Bee Colony Algorithm based on Decomposition

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A **Multiobjective Artificial Bee Colony (ABC) Algorithm based on Decomposition (MOEAD)** for solving normalised and scaled multi-objective optimisation problems (MOPs).

This repository provides **two independent implementations**:

| Language | Directory | Requirements |
|----------|-----------|-------------|
| **Python** | [`python/`](python/) | Python 3.10+, NumPy, SciPy, Matplotlib |
| **MATLAB** | [`matlab/`](matlab/) | MATLAB R2016b+ |

## Algorithm Overview

MOEAD-ABC decomposes a multi-objective problem into a set of scalar sub-problems using uniformly distributed weight vectors and applies an Artificial Bee Colony search strategy within the neighbourhood of each sub-problem. Key features:

- **Decomposition-based framework** with uniform weight vectors (Das & Dennis, 1998)
- **ABC search** with fitness-proportionate (roulette wheel) source selection
- **Polynomial mutation** for exploration
- **Four aggregation functions**: PBI, Tchebycheff, Normalised Tchebycheff, Modified Tchebycheff
- **Scalable** to many-objective problems via two-layer weight vector generation

## Quick Start

### Python

```bash
cd python
pip install -r requirements.txt
python main.py -algorithm moeadabc -problem zdt1 -N 100 -M 2
```

### MATLAB

```matlab
cd matlab
main('-algorithm', @MOEADABC, '-problem', @ZDT1, '-N', 100, '-M', 2)
```

See the individual [Python README](python/README.md) and [MATLAB README](matlab/README.md) for detailed usage and parameter descriptions.

## Repository Structure

```
MOABC/
├── README.md                  ← You are here
├── LICENSE
├── python/
│   ├── README.md
│   ├── requirements.txt
│   ├── main.py                Entry point (CLI)
│   ├── moeadabc.py            MOEAD-ABC algorithm
│   ├── global_config.py       Experiment configuration
│   ├── individual.py          Solution representation
│   ├── problem.py             Problem base class
│   ├── zdt1.py                ZDT1 benchmark
│   ├── uniform_point.py       Weight vector generation
│   ├── roulette_wheel.py      Roulette wheel selection
│   ├── igd.py                 IGD performance metric
│   └── draw.py                Plotting utilities
└── matlab/
    ├── README.md
    ├── main.m                 Entry point
    ├── MOEADABC.m             MOEAD-ABC algorithm
    ├── GLOBAL.m               Experiment configuration
    ├── INDIVIDUAL.m           Solution representation
    ├── PROBLEM.m              Problem base class
    ├── ZDT1.m                 ZDT1 benchmark
    ├── UniformPoint.m         Weight vector generation
    ├── SelfRouletteWheelSelection.m  Roulette wheel selection
    ├── IGD.m                  IGD performance metric
    └── Draw.m                 Plotting utilities
```

## Reference

> A Multiobjective Artificial Bee Colony Algorithm based on Decomposition,
> 11th International Conference on Evolutionary Computation Theory and Applications, 2019.

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
