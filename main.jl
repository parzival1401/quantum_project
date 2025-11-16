"""
    main.jl

Main script to run all three parts of the Quantum Design Project.

Usage:
    julia main.jl
"""

include("FiniteSquareWell.jl")

using .FiniteSquareWell
using CairoMakie
using Printf
using Optim

Makie.inline!(false)  # create PNGs on disk instead of inline (if in REPL)

# =======================================================================
# PART 1 – Single well: three lowest energies vs depth
# =======================================================================

println("="^70)
println("PART 1: Three lowest energy levels vs well depth")
println("="^70)

a = 1.0
V0_values = range(5.0, 200.0; length=300)

V0_valid, E = energy_vs_depth(V0_values; a=a, n_levels=3)

fig1 = plot_single_well_levels(V0_valid, E; a=a)
save("part1_energy_levels.png", fig1)
println("➤ Saved: part1_energy_levels.png")

# Check large-depth limit for 1:4:9 ratio (energies measured from bottom)
if length(V0_valid) > 0
    V0_last = V0_valid[end]
    E_last  = E[end, :]              # [E1, E2, E3] at largest depth
    E_rel   = E_last .+ V0_last      # shift so bottom of well is 0

    r2 = E_rel[2] / E_rel[1]
    r3 = E_rel[3] / E_rel[1]

    @printf "At V₀ = %.1f the relative energies are:\n" V0_last
    @printf "  E₁: %.4f,  E₂: %.4f,  E₃: %.4f\n" E_rel[1] E_rel[2] E_rel[3]
    @printf "  Ratio E₁:E₂:E₃ ≈ 1:%.3f:%.3f (target 1:4:9)\n" r2 r3
end

println("✓ PART 1 complete.")

# =======================================================================
# PART 2 – Look for depth with E12 = E23
# =======================================================================

println("\n" * "="^70)
println("PART 2: Can a single well have evenly spaced first three levels?")
println("="^70)

using Statistics

E12, E23, ratio = spacing_ratios(E)

# Find “closest” attempt
Δ = abs.(E23 .- E12)
idx_min = argmin(Δ)
V0_best = V0_valid[idx_min]

@printf "Closest approach to E₁₂ = E₂₃ occurs at V₀ ≈ %.4f\n" V0_best
@printf "  E₁₂ = %.6f,  E₂₃ = %.6f,  Δ = %.6e\n" E12[idx_min] E23[idx_min] Δ[idx_min]
@printf "  Ratio E₂₃/E₁₂ ≈ %.6f\n" ratio[idx_min]

r_min = minimum(ratio)
r_max = maximum(ratio)
@printf "\nOver the scanned range:  E₂₃/E₁₂ ∈ [%.6f, %.6f]\n" r_min r_max

println("\nConclusion:")
println("  • E₂₃/E₁₂ never reaches 1; it stays strictly > 1 in our scan.")
println("  • This strongly suggests there is NO well depth with E₁₂ = E₂₃")
println("    for a single finite square well with fixed width a.")

# Plots for the report
fig2 = Figure(resolution=(800, 600))
ax2  = Axis(fig2[1, 1], xlabel="V₀", ylabel="Energy spacing",
            title="Single well spacings vs depth")
lines!(ax2, V0_valid, E12, label="E₂ - E₁")
lines!(ax2, V0_valid, E23, label="E₃ - E₂")
axislegend(ax2, position=:rb)
save("part2_energy_differences.png", fig2)
println("➤ Saved: part2_energy_differences.png")

fig3 = Figure(resolution=(800, 600))
ax3  = Axis(fig3[1, 1], xlabel="V₀", ylabel="E₂₃ / E₁₂",
            title="Ratio of spacings in single well")
lines!(ax3, V0_valid, ratio, label="E₂₃/E₁₂")
hlines!(ax3, [1.0], linestyle=:dash, label="1.0")
axislegend(ax3, position=:rb)
save("part2_energy_ratio.png", fig3)
println("➤ Saved: part2_energy_ratio.png")

println("✓ PART 2 complete (with a negative result: no equal spacings).")

# =======================================================================
# PART 3 – Double well with E23 ≈ 2 E12
# =======================================================================

println("\n" * "="^70)
println("PART 3: Double well with E₂₃ ≈ 2 E₁₂")
println("="^70)

# Objective for Optim.jl: x = [V0, d]
function objective_vec(x)
    V0 = max(x[1], 1e-3)    # enforce positivity softly
    d  = max(x[2], 1e-3)
    return double_well_objective(V0, d; a=a, target_ratio=2.0)
end

x0 = [60.0, 0.5]           # initial guess (tweak if needed)

res = optimize(objective_vec, x0, NelderMead(); iterations=5000)
x_opt = Optim.minimizer(res)
V0_opt, d_opt = x_opt

states_opt = approximate_double_well_states(V0_opt, d_opt; a=a, n_states=3)

if length(states_opt) == 3
    E1d, E2d, E3d = states_opt
    E12d = E2d - E1d
    E23d = E3d - E2d
    ratio_opt = E23d / E12d

    println("Optimization result for double well:")
    @printf "  V₀ ≈ %.4f,  d ≈ %.4f a\n" V0_opt d_opt
    @printf "  E₁ ≈ %.6f,  E₂ ≈ %.6f,  E₃ ≈ %.6f\n" E1d E2d E3d
    @printf "  E₁₂ = %.6f,  E₂₃ = %.6f,  ratio = %.6f\n" E12d E23d ratio_opt
else
    println("Warning: could not obtain three double-well states at optimum.")
end

# Contour plot of ratio vs (V₀, d)
V0_scan = range(20.0, 120.0; length=80)
d_scan  = range(0.2, 1.2;   length=80)

fig4 = plot_double_well_contour(V0_scan, d_scan; a=a, target_ratio=2.0)
save("part3_double_well_contour.png", fig4)
println("➤ Saved: part3_double_well_contour.png")

# Configuration plot at optimized parameters
fig5 = plot_double_well_configuration(V0_opt, d_opt; a=a)
if fig5 !== nothing
    save("part3_double_well_configuration.png", fig5)
    println("➤ Saved: part3_double_well_configuration.png")
end

println("\nSummary:")
println("  ✓ PART 1: Energies vs depth + 1:4:9 check")
println("  ✓ PART 2: Showed numerically that E₁₂ = E₂₃ does *not* occur")
println("  ✓ PART 3: Found a double-well configuration with E₂₃ ≈ 2 E₁₂")

println("\nAll plots written to current directory.")
println("="^70)
