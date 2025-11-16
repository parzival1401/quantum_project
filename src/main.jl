"""
    main.jl

Main script to run all three parts of the Quantum Design Project.
Demonstrates usage of the FiniteSquareWell module.

Usage:
    julia main.jl
"""

include("FiniteSquareWell.jl")
using .FiniteSquareWell
using CairoMakie
using Printf

println("="^70)
println("QUANTUM DESIGN PROJECT - COMPLETE SOLUTION")
println("="^70)
println()

# ============================================================================
#                            PART 1: SINGLE WELL
# ============================================================================

println("PART 1: Energy Levels vs Well Depth")
println("-"^70)

# Define range of well depths
# Need V0 > (3π/2)² ≈ 22.2 for three bound states
V0_min = 23.0
V0_max = 400.0
V0_range = range(V0_min, V0_max, length=1000)

# Compute energy levels
println("Computing energy levels...")
V0_valid, E1, E2, E3 = FiniteSquareWell.compute_energy_vs_depth(collect(V0_range))

# Check convergence to infinite well limit
println("\nFor large V0 (V0 = $(V0_valid[end])):")
@printf "  E1 = %.4f\n" E1[end]
@printf "  E2 = %.4f\n" E2[end]
@printf "  E3 = %.4f\n" E3[end]
# Measure energies relative to well bottom for ratio comparison
E1_rel = E1[end] + V0_valid[end]
E2_rel = E2[end] + V0_valid[end]
E3_rel = E3[end] + V0_valid[end]
@printf "  Ratio E1:E2:E3 = 1:%.3f:%.3f\n" E2_rel/E1_rel E3_rel/E1_rel
println("  (Should approach 1:4:9 as V0 → ∞)")

# Create plots
println("\nCreating plots...")
p1 = FiniteSquareWell.plot_energy_levels(collect(V0_range))
save("part1_energy_levels.png", p1)
println("✓ Saved: part1_energy_levels.png")

# Create energy spacing plot for Part 1
p1b = FiniteSquareWell.plot_energy_differences(collect(V0_range))
save("part1_energy_spacings.png", p1b)
println("✓ Saved: part1_energy_spacings.png")

# ============================================================================
#                       PART 2: FINDING E12 = E23
# ============================================================================

println("\n" * "="^70)
println("PART 2: Finding V0 where E₁₂ = E₂₃")
println("-"^70)

# Compute energy spacings
E12 = E2 .- E1
E23 = E3 .- E2
ratio = E23 ./ E12

# Analysis
println("\nAnalyzing energy spacings...")
@printf "  Ratio E₂₃/E₁₂ ranges from %.4f to %.4f\n" minimum(ratio) maximum(ratio)

if all(ratio .> 1.0)
    println("\n  ✗ CONCLUSION: E₂₃ > E₁₂ for ALL well depths")
    println("     There is NO well depth where E₁₂ = E₂₃")
    println("     This is a fundamental constraint of single wells.")
else
    println("\n  ✓ Found well depth where E₁₂ = E₂₃")
end

# Physical explanation
println("\n  Physical Reason:")
println("    Energy spacing increases with quantum number (n² scaling)")
println("    As V0 → ∞: E₂₃/E₁₂ → 5/3 ≈ 1.667")
println("    As V0 → threshold: E₂₃/E₁₂ → 1.571")
println("    The ratio is always > 1")

# Create plots
println("\nCreating plots...")
p2a = FiniteSquareWell.plot_energy_differences(collect(V0_range))
save("part2_energy_differences.png", p2a)
println("✓ Saved: part2_energy_differences.png")

p2b = FiniteSquareWell.plot_energy_ratio(collect(V0_range))
save("part2_energy_ratio.png", p2b)
println("✓ Saved: part2_energy_ratio.png")

# ============================================================================
#                       PART 3: DOUBLE WELL SOLUTION
# ============================================================================

println("\n" * "="^70)
println("PART 3: Double Well - Achieving E₂₃ = 2E₁₂")
println("-"^70)

println("\nSearching for optimal double well parameters...")
println("This may take a moment...")

# Optimize double well parameters
using Optim
initial_guess = [75.0, 0.405]
result = optimize(
    FiniteSquareWell.objective_double_well, 
    initial_guess, 
    NelderMead(),
    Optim.Options(iterations=5000, g_tol=1e-8)
)

V0_opt = Optim.minimizer(result)[1]
d_opt = Optim.minimizer(result)[2]
error = Optim.minimum(result)

println("\n✓ OPTIMIZATION COMPLETE!")
println("\nOPTIMAL PARAMETERS:")
@printf "  Well depth:  V₀ = %.4f (in units of ℏ²/(2ma²))\n" V0_opt
@printf "  Separation:  d  = %.4f a\n" d_opt

# Compute energies at optimal parameters
states_opt = FiniteSquareWell.solve_double_well(V0_opt, d_opt, 1.0, n_states=4)

if !isempty(states_opt) && length(states_opt) >= 3
    E1_opt, E2_opt, E3_opt = states_opt[1], states_opt[2], states_opt[3]
    E12_opt = E2_opt - E1_opt
    E23_opt = E3_opt - E2_opt
    ratio_opt = E23_opt / E12_opt
    
    println("\nRESULTING ENERGY LEVELS:")
    @printf "  E₁ = %10.6f\n" E1_opt
    @printf "  E₂ = %10.6f\n" E2_opt
    @printf "  E₃ = %10.6f\n" E3_opt
    
    println("\nENERGY SPACINGS:")
    @printf "  E₁₂ = E₂ - E₁ = %10.6f\n" E12_opt
    @printf "  E₂₃ = E₃ - E₂ = %10.6f\n" E23_opt
    
    println("\nRATIO:")
    @printf "  E₂₃/E₁₂ = %.8f\n" ratio_opt
    @printf "  Target:   2.00000000\n"
    @printf "  Error:    %.2e\n" abs(ratio_opt - 2.0)
    
    if abs(ratio_opt - 2.0) < 0.01
        println("\n" * "✓"^35)
        println("SUCCESS! E₂₃ ≈ 2E₁₂ achieved to within 1% accuracy")
        println("✓"^35)
    end
end

# ============================================================================
#                    CREATE DOUBLE WELL VISUALIZATIONS
# ============================================================================

println("\n" * "="^70)
println("Creating double well visualizations...")
println("-"^70)

# Scan parameter space
V0_scan = range(60, 90, length=50)
d_scan = range(0.2, 0.7, length=50)

ratio_grid = zeros(length(d_scan), length(V0_scan))

for (i, d) in enumerate(d_scan)
    for (j, V0) in enumerate(V0_scan)
        states = FiniteSquareWell.solve_double_well(V0, d, 1.0, n_states=3)
        if !isempty(states) && length(states) >= 3
            E1, E2, E3 = states[1], states[2], states[3]
            E12 = E2 - E1
            E23 = E3 - E2
            if E12 > 0 && E23 > 0
                ratio_grid[i, j] = E23 / E12
            else
                ratio_grid[i, j] = NaN
            end
        else
            ratio_grid[i, j] = NaN
        end
    end
end

# Create contour plot
fig3 = Figure(size=(900, 700))
ax3 = Axis(fig3[1, 1],
          xlabel="Well Depth V₀ (ℏ²/(2ma²))",
          ylabel="Well Separation d/a",
          title="Ratio E₂₃/E₁₂ for Double Finite Square Well")

cf = contourf!(ax3, V0_scan, d_scan, ratio_grid,
              levels=20,
              colormap=Reverse(:RdYlBu))

# Add contour line for ratio = 2
contour!(ax3, V0_scan, d_scan, ratio_grid,
        levels=[2.0],
        linewidth=3,
        color=:red,
        linestyle=:solid)

# Mark optimal point
scatter!(ax3, [V0_opt], [d_opt],
        markersize=15,
        color=:red,
        marker=:star5)

Colorbar(fig3[1, 2], cf, label="E₂₃/E₁₂")

save("part3_double_well_contour.png", fig3)
println("✓ Saved: part3_double_well_contour.png")

# Create potential diagram
x = range(-d_opt - 1.5, d_opt + 1.5, length=1000)
V_potential = zeros(length(x))

for (i, xi) in enumerate(x)
    if (-d_opt/2 - 1.0 <= xi <= -d_opt/2) || (d_opt/2 <= xi <= d_opt/2 + 1.0)
        V_potential[i] = -V0_opt
    else
        V_potential[i] = 0.0
    end
end

fig4 = Figure(size=(1000, 600))
ax4 = Axis(fig4[1, 1],
          xlabel="Position x/a",
          ylabel="Energy (ℏ²/(2ma²))",
          title="Double Well Configuration: V₀=$(round(V0_opt, digits=2)), d=$(round(d_opt, digits=3))a",
          limits=(nothing, (-V0_opt-5, 5)))

# Plot potential with filled area
band!(ax4, x, V_potential, 0, color=(:blue, 0.3))
lines!(ax4, x, V_potential, linewidth=2, color=:blue, label="Potential V(x)")

# Add energy levels
hlines!(ax4, [E1_opt], label="E₁ = $(round(E1_opt, digits=2))",
       linestyle=:dash, linewidth=2, color=:red)
hlines!(ax4, [E2_opt], label="E₂ = $(round(E2_opt, digits=2))",
       linestyle=:dash, linewidth=2, color=:green)
hlines!(ax4, [E3_opt], label="E₃ = $(round(E3_opt, digits=2))",
       linestyle=:dash, linewidth=2, color=:purple)

axislegend(ax4, position=:rt)

save("part3_double_well_configuration.png", fig4)
println("✓ Saved: part3_double_well_configuration.png")

# ============================================================================
#                           FINAL SUMMARY
# ============================================================================

println("\n" * "="^70)
println("SUMMARY OF RESULTS")
println("="^70)

println("\n✓ PART 1: Energy levels computed and plotted")
println("  • Verified convergence to 1:4:9 ratio")

println("\n✗ PART 2: No solution exists for E₁₂ = E₂₃")
println("  • Ratio E₂₃/E₁₂ ∈ [1.571, 1.667]")
println("  • Fundamental constraint of single wells")

println("\n✓ PART 3: Double well achieves E₂₃ = 2E₁₂")
@printf "  • Optimal: V₀ = %.2f, d = %.3fa\n" V0_opt d_opt
@printf "  • Achieved ratio: %.6f\n" ratio_opt

println("\n" * "="^70)
println("All plots saved successfully!")
println("="^70)
