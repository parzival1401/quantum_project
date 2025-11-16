"""
    FiniteSquareWell.jl

Quantum mechanics calculations for finite square well potentials.
Implements single and double well solutions using Townsend's approach.

Author: Quantum Design Project
Date: November 2025
"""

module FiniteSquareWell

using LinearAlgebra
using Roots
using CairoMakie
using Printf
using Optimization
using OptimizationOptimJL

export solve_single_well, plot_energy_levels, find_equal_spacings
export solve_double_well, optimize_double_well

# ============================================================================
#                        SINGLE FINITE SQUARE WELL
# ============================================================================

"""
    transcendental_even(z, z0)

Transcendental equation for even parity states in a finite square well.

# Mathematical Background
For symmetric (even) wavefunctions, the boundary conditions lead to:
    tan(z) = sqrt((z0/z)² - 1)

where:
- z = a·sqrt(2mE/ℏ²) is the dimensionless energy parameter
- z0 = a·sqrt(2mV0/ℏ²) is the dimensionless well depth parameter
- a is the well width
- E is the energy (E < 0 for bound states)
- V0 is the well depth

# Arguments
- `z::Float64`: Dimensionless energy parameter
- `z0::Float64`: Dimensionless well depth parameter

# Returns
- `Float64`: Value of transcendental equation (zero at eigenvalues)
"""
function transcendental_even(z::Float64, z0::Float64)::Float64
    if z >= z0
        return Inf
    end
    
    # tan(z) - sqrt((z0/z)² - 1) = 0 at eigenvalues
    return tan(z) - sqrt((z0/z)^2 - 1)
end

"""
    transcendental_odd(z, z0)

Transcendental equation for odd parity states in a finite square well.

# Mathematical Background
For antisymmetric (odd) wavefunctions, the boundary conditions lead to:
    -cot(z) = sqrt((z0/z)² - 1)
    
Equivalently: tan(z) = -1/sqrt((z0/z)² - 1)

# Arguments
- `z::Float64`: Dimensionless energy parameter
- `z0::Float64`: Dimensionless well depth parameter

# Returns
- `Float64`: Value of transcendental equation (zero at eigenvalues)
"""
function transcendental_odd(z::Float64, z0::Float64)::Float64
    if z >= z0
        return Inf
    end
    
    # -cot(z) - sqrt((z0/z)² - 1) = 0 at eigenvalues
    # Equivalently: tan(z) + 1/sqrt((z0/z)² - 1) = 0
    return tan(z) + 1.0/sqrt((z0/z)^2 - 1)
end

"""
    find_bound_states(z0::Float64; max_states::Int=3)

Find bound state energies for a finite square well.

# Mathematical Background
The number of bound states is approximately ⌈z0/π⌉.
We search for roots in intervals:
- Even states: [nπ, (n+1/2)π]
- Odd states: [(n+1/2)π, (n+1)π]

# Arguments
- `z0::Float64`: Dimensionless well depth parameter
- `max_states::Int=3`: Maximum number of states to find

# Returns
- `Vector{Tuple{String, Float64}}`: List of (parity, z_value) pairs
"""
function find_bound_states(z0::Float64; max_states::Int=3)::Vector{Tuple{String, Float64}}
    bound_states = Tuple{String, Float64}[]
    
    # Maximum number of possible states
    n_max = ceil(Int, 2*z0/π) + 1
    
    # Search for even parity states
    for n in 0:n_max
        z_left = n * π + 0.001
        z_right = (n + 0.5) * π - 0.001
        
        if z_right >= z0
            break
        end
        
        try
            # Check for sign change (indicating a root)
            if transcendental_even(z_left, z0) * transcendental_even(z_right, z0) < 0
                # Find the root using Brent's method
                z_solution = find_zero(z -> transcendental_even(z, z0), 
                                      (z_left, z_right), Bisection())
                push!(bound_states, ("even", z_solution))
            end
        catch
            # Skip if root finding fails
            continue
        end
    end
    
    # Search for odd parity states
    for n in 0:n_max
        z_left = (n + 0.5) * π + 0.001
        z_right = (n + 1) * π - 0.001
        
        if z_right >= z0
            break
        end
        
        try
            if transcendental_odd(z_left, z0) * transcendental_odd(z_right, z0) < 0
                z_solution = find_zero(z -> transcendental_odd(z, z0), 
                                      (z_left, z_right), Bisection())
                push!(bound_states, ("odd", z_solution))
            end
        catch
            continue
        end
    end
    
    # Sort by energy (z value) and return requested number
    sort!(bound_states, by = x -> x[2])
    return bound_states[1:min(max_states, length(bound_states))]
end

"""
    solve_single_well(V0::Float64, a::Float64=1.0; max_states::Int=3)

Solve for bound states of a single finite square well.

# Mathematical Background
Energy eigenvalues E are related to z by:
    E = (ℏ²z²)/(2ma²) - V0

In our natural units (ℏ²/2m = 1), this becomes:
    E = z²/a² - V0

# Arguments
- `V0::Float64`: Well depth (in units of ℏ²/(2ma²))
- `a::Float64=1.0`: Well width
- `max_states::Int=3`: Number of states to compute

# Returns
- `Vector{Float64}`: Energy eigenvalues
"""
function solve_single_well(V0::Float64, a::Float64=1.0; max_states::Int=3)::Vector{Float64}
    # Dimensionless well depth parameter
    z0 = a * sqrt(2 * V0)
    
    # Find bound states
    states = find_bound_states(z0, max_states=max_states)
    
    # Convert z values to energies
    # E = z²/(2a²) - V0 in our natural units where ℏ²/(2m) = 1
    energies = [z^2 / (2*a^2) - V0 for (parity, z) in states]
    
    return energies
end

"""
    compute_energy_vs_depth(V0_range::AbstractVector{Float64}, a::Float64=1.0)

Compute the three lowest energy levels as a function of well depth.

# Arguments
- `V0_range::AbstractVector{Float64}`: Range of well depths to scan
- `a::Float64=1.0`: Well width

# Returns
- `Tuple`: (V0_valid, E1, E2, E3) arrays
"""
function compute_energy_vs_depth(V0_range::AbstractVector{Float64}, 
                                 a::Float64=1.0)
    E1_list = Float64[]
    E2_list = Float64[]
    E3_list = Float64[]
    V0_valid = Float64[]
    
    for V0 in V0_range
        energies = solve_single_well(V0, a, max_states=3)
        
        if length(energies) >= 3
            push!(E1_list, energies[1])
            push!(E2_list, energies[2])
            push!(E3_list, energies[3])
            push!(V0_valid, V0)
        end
    end
    
    return (V0_valid, E1_list, E2_list, E3_list)
end

# ============================================================================
#                        DOUBLE FINITE SQUARE WELL
# ============================================================================

"""
    approximate_double_well_states(a::Float64, d::Float64, V0::Float64; 
                                   n_states::Int=3)

Approximate double well energies using tight-binding/WKB approach.

# Mathematical Background
For a double well, single-well states split into symmetric/antisymmetric pairs
through quantum tunneling. The splitting is approximately:

    ΔE ≈ |E_single| · exp(-κd)

where κ = sqrt(-2mE/ℏ²) is the decay constant.

Each single-well state gives rise to two double-well states:
- E_symmetric = E_single - ΔE/2 (lower energy, bonding)
- E_antisymmetric = E_single + ΔE/2 (higher energy, antibonding)

# Arguments
- `a::Float64`: Well width
- `d::Float64`: Well separation
- `V0::Float64`: Well depth
- `n_states::Int=3`: Number of states to compute

# Returns
- `Vector{Float64}`: Double well energy levels (or nothing if insufficient states)
"""
function approximate_double_well_states(a::Float64, d::Float64, V0::Float64; 
                                       n_states::Int=3)
    # First solve single well to get base states
    single_energies = solve_single_well(V0, a, max_states=2)
    
    if length(single_energies) < 2
        return nothing
    end
    
    double_states = Float64[]
    
    # For each single-well state, compute the doublet splitting
    for E_single in single_energies[1:2]
        # Decay constant in barrier region
        κ = sqrt(-2 * E_single)
        
        # Tunneling-induced splitting (approximate)
        splitting = abs(E_single) * exp(-κ * d) * 2.0
        
        # Symmetric state (lower energy)
        E_sym = E_single - splitting/2
        # Antisymmetric state (higher energy)
        E_antisym = E_single + splitting/2
        
        push!(double_states, E_sym)
        push!(double_states, E_antisym)
    end
    
    # Sort by energy
    sort!(double_states)
    
    return double_states[1:min(n_states, length(double_states))]
end

"""
    objective_double_well(params::Vector{Float64})

Objective function for optimizing double well to achieve E23 = 2*E12.

# Arguments
- `params::Vector{Float64}`: [V0, d]

# Returns
- `Float64`: |E23/E12 - 2|
"""
function objective_double_well(params::Vector{Float64})::Float64
    V0, d = params
    
    # Constraints
    if V0 < 25.0 || d < 0.05
        return 1e10
    end
    
    states = approximate_double_well_states(1.0, d, V0, n_states=4)
    
    if states === nothing || length(states) < 3
        return 1e10
    end
    
    E1, E2, E3 = states[1], states[2], states[3]
    E12 = E2 - E1
    E23 = E3 - E2
    
    if E12 <= 0 || E23 <= 0
        return 1e10
    end
    
    ratio = E23 / E12
    return abs(ratio - 2.0)
end

"""
    optimize_double_well(initial_guess::Vector{Float64}=[75.0, 0.405])

Optimize double well parameters to achieve E23 = 2*E12.

# Arguments
- `initial_guess::Vector{Float64}`: Starting point [V0, d]

# Returns
- `Tuple`: (optimal_V0, optimal_d, error)
"""
function optimize_double_well(initial_guess::Vector{Float64}=[75.0, 0.405])
    # Use Nelder-Mead optimization
    result = optimize(objective_double_well, initial_guess, NelderMead(),
                     Optim.Options(iterations=5000, g_tol=1e-8))
    
    V0_opt, d_opt = Optim.minimizer(result)
    error = Optim.minimum(result)
    
    return (V0_opt, d_opt, error)
end

"""
    solve_double_well(V0::Float64, d::Float64, a::Float64=1.0; n_states::Int=3)

Solve for bound states of a double finite square well.

# Arguments
- `V0::Float64`: Well depth
- `d::Float64`: Well separation
- `a::Float64=1.0`: Well width
- `n_states::Int=3`: Number of states to compute

# Returns
- `Vector{Float64}`: Energy eigenvalues
"""
function solve_double_well(V0::Float64, d::Float64, a::Float64=1.0; 
                          n_states::Int=3)::Vector{Float64}
    states = approximate_double_well_states(a, d, V0, n_states=n_states)
    return states === nothing ? Float64[] : states
end

# ============================================================================
#                              PLOTTING FUNCTIONS
# ============================================================================

"""
    plot_energy_levels(V0_range::AbstractVector{Float64}; a::Float64=1.0)

Create plot of energy levels vs well depth.

# Arguments
- `V0_range::AbstractVector{Float64}`: Range of well depths
- `a::Float64=1.0`: Well width

# Returns
- `Figure`: The generated plot
"""
function plot_energy_levels(V0_range::AbstractVector{Float64}; a::Float64=1.0)
    V0_valid, E1, E2, E3 = compute_energy_vs_depth(V0_range, a)

    fig = Figure(size=(800, 600))
    ax = Axis(fig[1, 1],
              xlabel="Well Depth V₀ (ℏ²/(2ma²))",
              ylabel="Energy (ℏ²/(2ma²))",
              title="Energy Levels of Finite Square Well vs Well Depth")

    lines!(ax, V0_valid, E1, label="E₁ (ground state)",
           linewidth=2, color=:blue)
    lines!(ax, V0_valid, E2, label="E₂ (first excited)",
           linewidth=2, color=:red)
    lines!(ax, V0_valid, E3, label="E₃ (second excited)",
           linewidth=2, color=:green)

    axislegend(ax, position=:rt)

    return fig
end

"""
    plot_energy_differences(V0_range::AbstractVector{Float64}; a::Float64=1.0)

Create plot of energy level spacings vs well depth.

# Arguments
- `V0_range::AbstractVector{Float64}`: Range of well depths
- `a::Float64=1.0`: Well width

# Returns
- `Figure`: The generated plot
"""
function plot_energy_differences(V0_range::AbstractVector{Float64};
                                 a::Float64=1.0)
    V0_valid, E1, E2, E3 = compute_energy_vs_depth(V0_range, a)

    E12 = E2 .- E1
    E23 = E3 .- E2

    fig = Figure(size=(800, 600))
    ax = Axis(fig[1, 1],
              xlabel="Well Depth V₀ (ℏ²/(2ma²))",
              ylabel="Energy Difference (ℏ²/(2ma²))",
              title="Energy Level Spacings vs Well Depth")

    lines!(ax, V0_valid, E12, label="E₂ - E₁ (E₁₂)",
           linewidth=2, color=:blue)
    lines!(ax, V0_valid, E23, label="E₃ - E₂ (E₂₃)",
           linewidth=2, color=:red)

    axislegend(ax, position=:rt)

    return fig
end

"""
    plot_energy_ratio(V0_range::AbstractVector{Float64}; a::Float64=1.0)

Create plot of energy spacing ratio vs well depth.

# Arguments
- `V0_range::AbstractVector{Float64}`: Range of well depths
- `a::Float64=1.0`: Well width

# Returns
- `Figure`: The generated plot
"""
function plot_energy_ratio(V0_range::AbstractVector{Float64}; a::Float64=1.0)
    V0_valid, E1, E2, E3 = compute_energy_vs_depth(V0_range, a)

    E12 = E2 .- E1
    E23 = E3 .- E2
    ratio = E23 ./ E12

    fig = Figure(size=(800, 600))
    ax = Axis(fig[1, 1],
              xlabel="Well Depth V₀ (ℏ²/(2ma²))",
              ylabel="Ratio E₂₃/E₁₂",
              title="Ratio of Energy Spacings vs Well Depth",
              limits=(nothing, (0.5, 2.5)))

    lines!(ax, V0_valid, ratio,
           linewidth=2, color=:purple)

    hlines!(ax, [2.0], label="Ratio = 2",
            linestyle=:dash, color=:black, linewidth=2)
    hlines!(ax, [1.0], label="Ratio = 1",
            linestyle=:dash, color=(:gray, 0.5), linewidth=1)

    axislegend(ax, position=:rb)

    return fig
end

end # module FiniteSquareWell
