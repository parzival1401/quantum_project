# Quantum Finite Square Well Project

A computational physics project implementing numerical solutions for the finite square well problem in quantum mechanics using Julia.

## Project Overview

This project explores the quantum mechanical finite square well potential, implementing numerical methods to:
- Calculate energy levels and eigenstates
- Analyze energy spacings and ratios
- Investigate double-well configurations
- Visualize wave functions and probability densities

## Project Structure

```
quantum_project/
├── src/                    # Source code
│   ├── FiniteSquareWell.jl # Core implementation module
│   └── main.jl             # Main execution script
├── docs/                   # Documentation
│   ├── Mathematical_Background_Finite_Square_Well_CORRECTED.md
│   └── Mathematical_Background_Finite_Square_Well_CORRECTED.pdf
├── results/                # Generated plots and results
│   ├── part1_energy_levels.png
│   ├── part1_energy_spacings.png
│   ├── part2_energy_differences.png
│   ├── part2_energy_ratio.png
│   ├── part3_double_well_configuration.png
│   └── part3_double_well_contour.png
├── assets/                 # Project assets
│   ├── Quantum Design Project.pdf
│   └── adobe-express-qr-code 2.png
├── Project.toml            # Julia project dependencies
├── Manifest.toml           # Locked dependency versions
└── README.md               # This file
```

## Requirements

- Julia 1.x or higher
- Required packages (see `Project.toml`):
  - LinearAlgebra
  - Plots
  - Optim
  - QuadGK
  - Other dependencies as specified

## Installation

1. Clone this repository
2. Navigate to the project directory
3. Start Julia and activate the project environment:

```julia
using Pkg
Pkg.activate(".")
Pkg.instantiate()
```

## Usage

Run the main simulation:

```julia
include("src/main.jl")
```

Or use the module directly:

```julia
include("src/FiniteSquareWell.jl")
using .FiniteSquareWell
```

## Results

The simulation generates several plots saved in the `results/` directory:
- Energy level diagrams
- Energy spacing analysis
- Energy ratio comparisons
- Double-well configuration visualizations
- Probability density contour plots

## Documentation

Comprehensive mathematical background and theoretical foundations are available in the `docs/` directory:
- **Markdown:** [Mathematical_Background_Finite_Square_Well_CORRECTED.md](docs/Mathematical_Background_Finite_Square_Well_CORRECTED.md)
- **PDF:** [Mathematical_Background_Finite_Square_Well_CORRECTED.pdf](docs/Mathematical_Background_Finite_Square_Well_CORRECTED.pdf)

The documentation includes:
- Complete derivation of transcendental equations for bound states
- Mathematical proof that E₁₂ ≠ E₂₃ in single wells
- Analysis of double-well configurations and energy level engineering
- Numerical methods and optimization techniques
- Detailed figures and visualizations

## License

Academic project for Fall 2025 Quantum Physics course.

## Authors

- Fernando Delgado
- Kendal Trellue

---

For more details, see the project specification in `assets/Quantum Design Project.pdf`.
