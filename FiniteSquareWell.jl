"""
    FiniteSquareWell.jl

Quantum–mechanics helpers for the finite square well project.

We work in units with ℏ²/2m = 1. The square well is
    V(x) = -V0   for |x| < a/2
           0     otherwise

All energies are measured relative to V = 0 outside the well,
so bound states satisfy -V0 < E < 0.
"""
module FiniteSquareWell

using LinearAlgebra
using Roots
using CairoMakie
using Printf

export solve_single_well,
       energy_vs_depth,
       plot_single_well_levels,
       spacing_ratios,
       approximate_double_well_states,
       double_well_objective,
       plot_double_well_contour,
       plot_double_well_configuration

# ============================================================================
#                    SINGLE FINITE SQUARE WELL HELPERS
# ============================================================================

"""
    z0(V0, a)

Dimensionless well–depth parameter

    z0 = (a/2) * √V0

using units ℏ²/2m = 1.
"""
z0(V0::Float64, a::Float64) = 0.5 * a * sqrt(V0)

"""
    energy_from_z(z, V0, a)

Convert the dimensionless parameter `z` into the physical energy E:

    z = k a / 2,   k = √(E + V0)   (inside the well)
    ⇒ E = -V0 + 4 z² / a²
"""
function energy_from_z(z::Float64, V0::Float64, a::Float64)
    return -V0 + 4.0 * z^2 / a^2
end

# --- transcendental equations ----------------------------------------------

"""
    f_even(z, z0)

Transcendental equation for even-parity bound states:

    z tan z = √(z0² - z²)

We return f(z) whose zeros give allowed z.
"""
function f_even(z::Float64, z0::Float64)
    if z <= 0 || z >= z0
        return NaN
    end
    return z * tan(z) - sqrt(z0^2 - z^2)
end

"""
    f_odd(z, z0)

Transcendental equation for odd-parity bound states:

    -z cot z = √(z0² - z²)
"""
function f_odd(z::Float64, z0::Float64)
    if z <= 0 || z >= z0
        return NaN
    end
    return -z * cot(z) - sqrt(z0^2 - z^2)
end

"""
    solve_single_well(V0; a=1.0, max_states=10)

Return all bound state energies of a single finite square well.

Arguments
---------
- `V0`          : positive well depth
- `a`           : well width
- `max_states`  : safety cap on number of roots to look for

Returns
-------
- `Vector{Float64}` of energies `E₁ < E₂ < ... < 0`.
"""
function solve_single_well(V0::Float64; a::Float64=1.0, max_states::Int=10)
    V0 <= 0 && return Float64[]

    z0_val = z0(V0, a)
    energies = Float64[]

    # Even states lie in intervals (nπ, nπ + π/2), odd in (nπ+π/2, (n+1)π)
    # but all must satisfy z < z0.
    # We search each interval with a bracketed root finder.
    n_max = max_states + 5  # a bit generous

    # Even states
    for n in 0:n_max
        left  = n * π + 1e-3
        right = n * π + π/2 - 1e-3
        if left >= z0_val
            break
        end
        right = min(right, z0_val - 1e-3)
        left >= right && continue

        f(z) = f_even(z, z0_val)
        if !isfinite(f(left)) || !isfinite(f(right)) || sign(f(left)) == sign(f(right))
            continue
        end
        try
            root = find_zero((f, left, right), Bisection())
            if 0 < root < z0_val
                push!(energies, energy_from_z(root, V0, a))
            end
        catch
            # no root in this interval
        end
    end

    # Odd states
    for n in 0:n_max
        left  = n * π + π/2 + 1e-3
        right = (n + 1) * π - 1e-3
        if left >= z0_val
            break
        end
        right = min(right, z0_val - 1e-3)
        left >= right && continue

        f(z) = f_odd(z, z0_val)
        if !isfinite(f(left)) || !isfinite(f(right)) || sign(f(left)) == sign(f(right))
            continue
        end
        try
            root = find_zero((f, left, right), Bisection())
            if 0 < root < z0_val
                push!(energies, energy_from_z(root, V0, a))
            end
        catch
        end
    end

    sort!(energies)
    if length(energies) > max_states
        resize!(energies, max_states)
    end
    return energies
end

"""
    energy_vs_depth(V0_values; a=1.0, n_levels=3)

Compute the lowest `n_levels` energies for each depth in `V0_values`.

Returns
-------
- `V0_valid :: Vector{Float64}`  : those depths that had at least `n_levels` bound states
- `E       :: Matrix{Float64}`   : size (length(V0_valid), n_levels)
"""
function energy_vs_depth(V0_values::AbstractVector{<:Real};
                         a::Float64 = 1.0,
                         n_levels::Int = 3)

    V0_valid = Float64[]
    E = Float64[]

    for V0_val in V0_values
        energies = solve_single_well(float(V0_val); a=a, max_states=n_levels)
        if length(energies) >= n_levels
            push!(V0_valid, float(V0_val))
            append!(E, energies[1:n_levels])
        end
    end

    n = length(V0_valid)
    if n == 0
        return V0_valid, Array{Float64}(undef, 0, n_levels)
    end

    E_mat = reshape(E, (n_levels, n))'  # rows = depths, cols = level index
    return V0_valid, E_mat
end

"""
    spacing_ratios(E)

Given a matrix of energies E(i, n) where i indexes depth and n
indexes level (1,2,3), compute

    E12 = E₂ - E₁
    E23 = E₃ - E₂
    ratio = E23 ./ E12

Returns `(E12, E23, ratio)`.
"""
function spacing_ratios(E::AbstractMatrix{<:Real})
    @assert size(E, 2) >= 3 "Need at least three levels per depth"
    E1 = E[:, 1]
    E2 = E[:, 2]
    E3 = E[:, 3]
    E12 = E2 .- E1
    E23 = E3 .- E2
    ratio = E23 ./ E12
    return E12, E23, ratio
end

"""
    plot_single_well_levels(V0_values, E; a=1.0)

Make a CairoMakie figure of the first three energies vs depth.
"""
function plot_single_well_levels(V0_values::AbstractVector,
                                 E::AbstractMatrix;
                                 a::Float64=1.0)
    fig = Figure(resolution=(800, 600))
    ax = Axis(fig[1, 1],
              xlabel="Well depth V₀",
              ylabel="Energy Eₙ",
              title="Single finite square well (a = $(@sprintf("%.2f", a)))")

    lines!(ax, V0_values, E[:, 1], label="E₁")
    lines!(ax, V0_values, E[:, 2], label="E₂")
    lines!(ax, V0_values, E[:, 3], label="E₃")

    axislegend(ax, position=:rb)
    return fig
end

# ============================================================================
#                        DOUBLE WELL (APPROXIMATE)
# ============================================================================

"""
    approximate_double_well_states(V0, d; a=1.0, n_states=3)

Approximate the lowest energy levels of a symmetric double well made
from two identical single wells of depth V0 and width a, separated by
a barrier of width d (flat at V = 0).

We take the ground and first excited single-well energies `E₁, E₂`
and build tunneling doublets:

    E₁ᵈ ± Δ₁/2  from E₁
    E₂ᵈ        (mostly unchanged)

with a splitting
    Δ₁(V0, d) ≈ C |E₁| exp(-κ d), κ = √(-2E₁)

This is a *model*, not an exact solution, but it behaves correctly:
splitting shrinks as d grows.
"""
function approximate_double_well_states(V0::Float64, d::Float64;
                                        a::Float64=1.0,
                                        n_states::Int=3)
    d <= 0 && return Float64[]
    V0 <= 0 && return Float64[]

    single = solve_single_well(V0; a=a, max_states=2)
    length(single) < 2 && return Float64[]

    E1, E2 = single[1], single[2]

    # decay constant in barrier, using outside potential = 0
    κ = sqrt(-2 * E1)

    # phenomenological prefactor; tuned just to give reasonable scales
    C = 0.6
    Δ1 = C * abs(E1) * exp(-κ * d)

    E_sym   = E1 - Δ1/2      # lowest
    E_antis = E1 + Δ1/2      # next
    E3      = E2             # third level mostly stays put

    states = [E_sym, E_antis, E3]
    n_states < 3 && resize!(states, n_states)
    sort!(states)
    return states
end

"""
    double_well_objective(V0, d; a=1.0, target_ratio=2.0)

Compute

    ratio = (E₃ - E₂) / (E₂ - E₁)

for the approximate double well, and return |ratio - target_ratio|.
If fewer than 3 states are available, returns a large penalty.
"""
function double_well_objective(V0::Float64, d::Float64;
                               a::Float64=1.0,
                               target_ratio::Float64=2.0)
    states = approximate_double_well_states(V0, d; a=a, n_states=3)
    if length(states) < 3
        return 1e3
    end

    E1, E2, E3 = states
    E12 = E2 - E1
    E23 = E3 - E2
    E12 <= 0 && return 1e3
    ratio = E23 / E12
    return abs(ratio - target_ratio)
end

"""
    plot_double_well_contour(V0_range, d_range; a=1.0, target_ratio=2.0)

Make a contour plot of the ratio (E₃ - E₂)/(E₂ - E₁) as a function of
(V₀, d/a). The target contour (e.g. = 2) is overlaid.
"""
function plot_double_well_contour(V0_range::AbstractVector,
                                  d_range::AbstractVector;
                                  a::Float64=1.0,
                                  target_ratio::Float64=2.0)

    nV = length(V0_range)
    nd = length(d_range)
    ratio = fill(NaN, nV, nd)

    for (i, V0) in enumerate(V0_range)
        for (j, d) in enumerate(d_range)
            states = approximate_double_well_states(V0, d; a=a, n_states=3)
            if length(states) == 3
                E1, E2, E3 = states
                E12 = E2 - E1
                E23 = E3 - E2
                if E12 > 0
                    ratio[i, j] = E23 / E12
                end
            end
        end
    end

    fig = Figure(resolution=(800, 600))
    ax = Axis(fig[1, 1],
              xlabel="V₀",
              ylabel="d / a",
              title="Double well spacing ratio (E₃ - E₂)/(E₂ - E₁)")

    # Makie expects matrix with dimensions (length(x), length(y)),
    # here ratio[i, j] corresponds to V0[i], d[j]
    contourf!(ax, V0_range, d_range, ratio'; levels=20)
    contour!(ax, V0_range, d_range, ratio'; levels=[target_ratio],
             linewidth=2)

    Colorbar(fig[1, 2], ax, label="ratio")
    return fig
end

"""
    plot_double_well_configuration(V0, d; a=1.0)

Plot the double-well potential and the three approximate energy levels.
"""
function plot_double_well_configuration(V0::Float64, d::Float64;
                                        a::Float64=1.0)
    states = approximate_double_well_states(V0, d; a=a, n_states=3)
    length(states) == 3 || return nothing

    E1, E2, E3 = states

    # Build 1D potential profile
    L = 2a + d + a  # total span
    x = range(-L/2, L/2; length=800)
    V = zeros(length(x))

    left_center  = - (d + a) / 2
    right_center = + (d + a) / 2
    half_a = a / 2

    for (k, xx) in enumerate(x)
        in_left  = abs(xx - left_center)  < half_a
        in_right = abs(xx - right_center) < half_a
        if in_left || in_right
            V[k] = -V0
        else
            V[k] = 0.0
        end
    end

    fig = Figure(resolution=(800, 600))
    ax  = Axis(fig[1, 1],
               xlabel="x",
               ylabel="Energy / Potential",
               title=@sprintf("Double well: V₀ = %.2f, d = %.3f a", V0, d))

    lines!(ax, x, V; label="V(x)")

    hlines!(ax, [E1]; color = :red,  linewidth=2, label="E₁")
    hlines!(ax, [E2]; color = :green, linewidth=2, label="E₂")
    hlines!(ax, [E3]; color = :blue, linewidth=2, label="E₃")

    axislegend(ax, position=:rt)
    return fig
end

end # module
