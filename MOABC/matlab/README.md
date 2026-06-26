# MOEAD-ABC — MATLAB Implementation

Multi-Objective Artificial Bee Colony Algorithm based on Decomposition.

## Requirements

- MATLAB R2016b or later

## Usage

```matlab
% Run MOEAD-ABC on ZDT1 with default settings
main('-algorithm', @MOEADABC, '-problem', @ZDT1, '-N', 100, '-M', 2)

% Run with custom evaluation budget
main('-algorithm', @MOEADABC, '-problem', @ZDT1, '-N', 200, '-M', 2, '-evaluation', 20000)

% Run 10 independent runs, saving 5 intermediate populations each
for i = 1:10
    main('-algorithm', @MOEADABC, '-problem', @ZDT1, '-run', i, '-save', 5)
end
```

## Parameters

| Parameter      | Type              | Description                            |
|---------------|-------------------|----------------------------------------|
| `-N`          | positive integer  | Population size                        |
| `-M`          | positive integer  | Number of objectives                   |
| `-D`          | positive integer  | Number of decision variables           |
| `-algorithm`  | function handle   | Algorithm function (e.g., `@MOEADABC`) |
| `-problem`    | function handle   | Problem function (e.g., `@ZDT1`)       |
| `-evaluation` | positive integer  | Maximum number of evaluations          |
| `-run`        | positive integer  | Run number                             |
| `-save`       | integer           | Number of saved populations            |
| `-outputFcn`  | function handle   | Function invoked after each generation |

## Files

| File                          | Description                                 |
|-------------------------------|---------------------------------------------|
| `main.m`                      | Entry point                                 |
| `MOEADABC.m`                  | MOEAD-ABC algorithm                         |
| `GLOBAL.m`                    | Experiment configuration class              |
| `INDIVIDUAL.m`                | Individual (solution) class                 |
| `PROBLEM.m`                   | Problem base class                          |
| `ZDT1.m`                      | ZDT1 benchmark problem                      |
| `UniformPoint.m`              | Uniform weight vector generation            |
| `SelfRouletteWheelSelection.m`| Roulette wheel selection                    |
| `IGD.m`                       | Inverted Generational Distance metric       |
| `Draw.m`                      | Plotting utility                            |

## Reference

> A Multiobjective Artificial Bee Colony Algorithm based on Decomposition,
> 11th International Conference on Evolutionary Computation Theory and Applications, 2019.
