# MOEAD-ABC — Python Implementation

Multi-Objective Artificial Bee Colony Algorithm based on Decomposition.

## Requirements

- Python 3.10+
- NumPy, SciPy, Matplotlib

```bash
pip install -r requirements.txt
```

## Usage

```bash
# Run MOEAD-ABC on ZDT1 with default settings
python main.py -algorithm moeadabc -problem zdt1 -N 100 -M 2

# With custom evaluation budget
python main.py -algorithm moeadabc -problem zdt1 -N 200 -M 2 -evaluation 20000

# Choose aggregation function type (1=PBI, 2=Tchebycheff, 3=Normalised, 4=Modified)
python main.py -algorithm moeadabc -problem zdt1 -N 100 -M 2 -agg_type 3

# Save 5 intermediate populations and specify run number
python main.py -algorithm moeadabc -problem zdt1 -N 100 -M 2 -save 5 -run 1
```

## Parameters

| Parameter      | Type   | Default  | Description                                      |
|---------------|--------|----------|--------------------------------------------------|
| `-algorithm`  | str    | moeadabc | Algorithm to run                                 |
| `-problem`    | str    | zdt1     | Test problem                                     |
| `-N`          | int    | 100      | Population size                                  |
| `-M`          | int    | 2        | Number of objectives                             |
| `-D`          | int    | 0        | Number of decision variables (0 = problem default)|
| `-evaluation` | int    | 10000    | Maximum number of evaluations                    |
| `-run`        | int    | 1        | Run number                                       |
| `-save`       | int    | 0        | Number of intermediate populations to save       |
| `-agg_type`   | int    | 1        | Aggregation function type (1–4)                  |

## Files

| File               | Description                                 |
|--------------------|---------------------------------------------|
| `main.py`          | CLI entry point                             |
| `moeadabc.py`      | MOEAD-ABC algorithm                         |
| `global_config.py` | Experiment configuration class              |
| `individual.py`    | Individual (solution) class                 |
| `problem.py`       | Problem base class                          |
| `zdt1.py`          | ZDT1 benchmark problem                      |
| `uniform_point.py` | Uniform weight vector generation            |
| `roulette_wheel.py`| Roulette wheel selection                    |
| `igd.py`           | Inverted Generational Distance metric       |
| `draw.py`          | Plotting utility (Matplotlib)               |

## Reference

> A Multiobjective Artificial Bee Colony Algorithm based on Decomposition,
> 11th International Conference on Evolutionary Computation Theory and Applications, 2019.
