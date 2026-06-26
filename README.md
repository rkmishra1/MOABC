<div align="center">

# 🐝 MOEAD-ABC

### Multi-Objective Artificial Bee Colony Algorithm based on Decomposition

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Python](https://img.shields.io/badge/Python-3.10%2B-3776AB?logo=python&logoColor=white)](python/)
[![MATLAB](https://img.shields.io/badge/MATLAB-R2016b%2B-0076A8?logo=mathworks&logoColor=white)](matlab/)
[![Conference](https://img.shields.io/badge/ECTA-2019-blueviolet)](https://www.scitepress.org/PublishedPapers/2019/)

*A decomposition-based multi-objective optimizer combining MOEA/D with Artificial Bee Colony search*

</div>

---

## Overview

**MOEAD-ABC** decomposes a multi-objective optimisation problem (MOP) into scalar sub-problems via uniformly distributed weight vectors, then applies an Artificial Bee Colony search within each sub-problem's neighbourhood. Supports normalised and scaled MOPs out of the box.

### Key Features

| Feature | Details |
|---|---|---|
| **Decomposition** | Uniform weight vectors (Das & Dennis, 1998) |
| **Search strategy** | ABC with fitness-proportionate roulette wheel selection |
| **Exploration** | Polynomial mutation |
| **Aggregation functions** | PBI · Tchebycheff · Normalised Tchebycheff · Modified Tchebycheff |
| **Scalability** | Two-layer weight generation for many-objective problems |

---

## Implementations

Two independent, self-contained implementations — pick the one that fits your stack:

| Language | Directory | Requirements |
|---|---|---|
| 🐍 **Python** | [`python/`](python/) | Python 3.10+, NumPy, SciPy, Matplotlib |
| 🔢 **MATLAB** | [`matlab/`](matlab/) | MATLAB R2016b+ |

---

## Quick Start

### 🐍 Python

```bash
cd python
pip install -r requirements.txt
python main.py -algorithm moeadabc -problem zdt1 -N 100 -M 2
```

### 🔢 MATLAB

```matlab
cd matlab
main('-algorithm', @MOEADABC, '-problem', @ZDT1, '-N', 100, '-M', 2)
```

> See [python/README.md](python/README.md) and [matlab/README.md](matlab/README.md) for full parameter references.

---

## Repository Structure

```
MOABC/
├── python/
│   ├── main.py                # Entry point (CLI)
│   ├── moeadabc.py            # MOEAD-ABC algorithm
│   ├── global_config.py       # Experiment configuration
│   ├── individual.py          # Solution representation
│   ├── problem.py             # Problem base class
│   ├── zdt1.py                # ZDT1 benchmark
│   ├── uniform_point.py       # Weight vector generation
│   ├── roulette_wheel.py      # Roulette wheel selection
│   ├── igd.py                 # IGD performance metric
│   ├── draw.py                # Plotting utilities
│   └── requirements.txt
└── matlab/
    ├── main.m                 % Entry point
    ├── MOEADABC.m             % MOEAD-ABC algorithm
    ├── GLOBAL.m               % Experiment configuration
    ├── INDIVIDUAL.m           % Solution representation
    ├── PROBLEM.m              % Problem base class
    ├── ZDT1.m                 % ZDT1 benchmark
    ├── UniformPoint.m         % Weight vector generation
    ├── SelfRouletteWheelSelection.m
    ├── IGD.m                  % IGD performance metric
    └── Draw.m                 % Plotting utilities
```

---

## Reference

If you use this code, please cite:

> **A Multiobjective Artificial Bee Colony Algorithm based on Decomposition**
> *11th International Conference on Evolutionary Computation Theory and Applications (ECTA), 2019.*

---

## License

Released under the [MIT License](LICENSE).
