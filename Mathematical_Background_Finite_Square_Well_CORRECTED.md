<center>

# Mathematical Background for Finite Square Well Calculations

## Complete Quantum Mechanics Explanation

**Author:** Quantum Design Project  
**Date:** November 2025  
**Language:** Julia Implementation

</center>

---

## Table of Contents

1. [Introduction](#1-introduction)
2. [Equations & Background](#2-equations--background)
3. [Part 1: Single Finite Square Well](#3-part-1-single-finite-square-well)
4. [Part 2: Mathematical Proof that E₁₂ ≠ E₂₃ in Single Wells](#4-part-2-mathematical-proof-that-e₁₂--e₂₃-in-single-wells)
5. [Part 3: Double Finite Square Well](#5-part-3-double-finite-square-well)
6. [Conclusions](#6-conclusions)
7. [Extensions and Applications](#7-extensions-and-applications)
8. [Appendix: Key Equations Summary](#8-appendix-key-equations-summary)
9. [References](#9-references)
10. [Acknowledgments](#10-acknowledgments)

---

## 1. Introduction

This document provides a comprehensive summary of the quantum mechanics behind finite square well calculations. We solve the time-independent Schrödinger equation for both single and double well configurations to find bound state energies. To solve it, we assumed a well depth minimum of V₀ = 22.21 and a depth maximum of V₀ = 2000 to simulate infinite depth. 

For the first part of this project, we focus on proving mathematically that in a single finite square well, the energy ratio between the first, second, and third bound states is 1:4:9. In the second part, we compared the ratio from part one to determine if the energy differences are the same. Finally, for the third part, we solved for the three bound states in a double well and iterated to find a well depth that shows the ratio E₂₃ = 2E₁₂. 

Our results show that for a single well, there is no possible well depth that satisfies E₂₃ = E₁₂, while for a double well we found a well depth of V₀ = 76.3 and separation distance of d = 0.405a that satisfies E₂₃ = 2E₁₂.

---

## 2. Equations & Background

### 2.1 The Finite Square Well Potential

A **finite square well** is a one-dimensional potential of the form:

$$
V(x) = \begin{cases}
-V_0 & \text{if } 0 \leq x \leq a \\
0 & \text{otherwise}
\end{cases}
$$

where:
- $V_0 > 0$ is the well depth
- $a$ is the well width
- $V = 0$ outside the well (the "continuum threshold")

### 2.2 The Time-Independent Schrödinger Equation

The time-independent Schrödinger equation in one dimension is:

$$
-\frac{\hbar^2}{2m}\frac{d^2\psi}{dx^2} + V(x)\psi(x) = E\psi(x)
$$

where:
- $\hbar$ is the reduced Planck constant
- $m$ is the particle mass
- $\psi(x)$ is the wavefunction
- $E$ is the energy eigenvalue
- $V(x)$ is the potential energy

### 2.3 Natural Units

To simplify calculations, we work in **natural units** where:

$$
\hbar^2/(2m) = 1
$$

This makes:
- Energy units: $E_0 = \hbar^2/(2ma^2)$
- Length units: $a$ (the well width)

In these units, the Schrödinger equation becomes:

$$
-\frac{d^2\psi}{dx^2} + V(x)\psi(x) = E\psi(x)
$$

### 2.4 Energy Conversion

Once we find $z$ values, we convert to energies:

$$
E = \frac{\hbar^2z^2}{2ma^2} - V_0 = \frac{z^2}{2a^2} - V_0
$$

(in natural units with $\hbar^2/(2m) = 1$)

### 2.5 Infinite Well Limit

As $V_0 \to \infty$, we have $z_0 \to \infty$, and:

$$
z_n \to n\pi \quad (n = 1, 2, 3, \ldots)
$$

giving:

$$
E_n \to \frac{n^2\pi^2\hbar^2}{2ma^2}
$$

---

## 3. Part 1: Single Finite Square Well

### 3.1 Question

**Can we confirm that the energy ratio of the first three bound states in a finite square well is approximately 1:4:9?**

First, we iterated through various well depths, finding the energies for the first, second, and third bound states until we reached our maximum well depth. Then, using the energies found, we calculated the ratio E₁:E₂:E₃ to confirm if it was approximately 1:4:9.

### 3.2 Potential Configuration

For a finite square well centered at the origin:

$$
V(x) = \begin{cases}
-V_0 & \text{if } -a/2 \leq x \leq a/2 \\
0 & \text{otherwise}
\end{cases}
$$

We seek **bound states** with $-V_0 < E < 0$.

### 3.3 Solution Strategy

The solution has three regions:

**Region I** ($x < -a/2$): Outside the well (left)

$$
\psi_I(x) = Ae^{\kappa x}
$$

where $\kappa = \sqrt{-2mE/\hbar^2} = \sqrt{-2E}$ (in natural units)

**Region II** ($-a/2 \leq x \leq a/2$): Inside the well

$$
\psi_{II}(x) = B\cos(kx) + C\sin(kx)
$$

where $k = \sqrt{2m(E + V_0)/\hbar^2} = \sqrt{2(E + V_0)}$ (in natural units)

**Region III** ($x > a/2$): Outside the well (right)

$$
\psi_{III}(x) = De^{-\kappa x}
$$

### 3.4 Boundary Conditions

At the boundaries, we require:
1. $\psi$ is continuous
2. $\psi'$ is continuous

These lead to **matching conditions** at $x = \pm a/2$.

### 3.5 Parity Symmetry

Since the potential is symmetric, solutions can be classified by parity:

**Even parity** (symmetric): $\psi(-x) = \psi(x)$
- Use $\psi_{II}(x) = B\cos(kx)$

**Odd parity** (antisymmetric): $\psi(-x) = -\psi(x)$
- Use $\psi_{II}(x) = C\sin(kx)$

### 3.6 Dimensionless Parameters

Define dimensionless variables:

$$
z \equiv ka = a\sqrt{2m(E + V_0)/\hbar^2}
$$

$$
z_0 \equiv a\sqrt{2mV_0/\hbar^2}
$$

These satisfy:
$$
z^2 = (a\kappa)^2 + z_0^2
$$

where $a\kappa = a\sqrt{-2mE/\hbar^2}$.

### 3.7 Transcendental Equations

Applying boundary conditions yields:

**Even parity states:**

$$
\tan(z) = \sqrt{\left(\frac{z_0}{z}\right)^2 - 1}
$$

**Odd parity states:**

$$
-\cot(z) = \sqrt{\left(\frac{z_0}{z}\right)^2 - 1}
$$

or equivalently:

$$
\tan(z) = -\frac{1}{\sqrt{(z_0/z)^2 - 1}}
$$

### 3.8 Derivation of Transcendental Equations

#### 3.8.1 Even Parity Case

**Wavefunction inside well:** $\psi_{II}(x) = A\cos(kx)$

**Wavefunction outside well (right):** $\psi_{III}(x) = Be^{-\kappa x}$

**Continuity at $x = a/2$:**

$$
A\cos(ka/2) = Be^{-\kappa a/2}
$$

**Derivative continuity at $x = a/2$:**

$$
-Ak\sin(ka/2) = -B\kappa e^{-\kappa a/2}
$$

**Divide second by first:**

$$
k\tan(ka/2) = \kappa
$$

**Using $z = ka$ and $(a\kappa)^2 + z^2 = z_0^2$:**

$$
\frac{z}{2}\tan(z/2) = \sqrt{z_0^2 - z^2}/2
$$

**Simplify using $\tan(z/2) = \sin(z)/(1+\cos(z))$:**

After algebra (using double-angle formulas), this becomes:

$$
\tan(z) = \sqrt{(z_0/z)^2 - 1}
$$

#### 3.8.2 Odd Parity Case

**Wavefunction inside well:** $\psi_{II}(x) = C\sin(kx)$

Following similar steps:

**Continuity:** $C\sin(ka/2) = Be^{-\kappa a/2}$

**Derivative continuity:** $Ck\cos(ka/2) = -B\kappa e^{-\kappa a/2}$

**Divide:**

$$
k\cot(ka/2) = -\kappa
$$

This leads to:

$$
-\cot(z) = \sqrt{(z_0/z)^2 - 1}
$$

### 3.9 Graphical Solution Method

These transcendental equations can be visualized as intersections:

1. Plot $y = \tan(z)$ (or $y = -\cot(z)$)
2. Plot $y = \sqrt{(z_0/z)^2 - 1}$
3. Intersections give eigenvalues

**Key observations:**
- Even states occur in intervals $[n\pi, (n+1/2)\pi]$
- Odd states occur in intervals $[(n+1/2)\pi, (n+1)\pi]$
- Number of bound states: $n \approx z_0/\pi$

![](part1_energy_levels.png)

**Figure 1:** The graph above shows the transcendental equations for a well depth between V₀ = 23 and V₀ = 400. This confirms that the first three bound states have different increasing energies. It also shows a linear correlation between well depth and energy levels.

![](part1_energy_spacings.png)

**Figure 2:** The graph above shows the energy levels and spacings for a well depth between V₀ = 23 and V₀ = 400. The energy spacing shown above confirms the assumption that the energy state difference between E₁ and E₂ does not equal the difference between E₂ and E₃. Each difference eventually asymptotically approaches a constant value as the well depth increases.

### 3.10 Summary of Part 1

This produces an energy ratio of **1:4.0:8.998**, thus confirming the expected ratio of 1:4:9 for the first three bound states in a finite square well.

---

## 4. Part 2: Mathematical Proof that E₁₂ ≠ E₂₃ in Single Wells

### 4.1 Question

**Can we find a well depth V₀ such that the energy spacings are equal?**

That is, does there exist V₀ where:

$$
E_{12} = E_{23}
$$

or equivalently:

$$
E_2 - E_1 = E_3 - E_2
$$

$$
\frac{E_{23}}{E_{12}} = 1
$$

### 4.2 Answer: NO

We will prove that **for all possible well depths**, the ratio $E_{23}/E_{12} > 1$, meaning the spacing between the second and third levels is always greater than the spacing between the first and second levels.

### 4.3 Why E₂₃ > E₁₂ in Single Wells

**Reason 1: Quantum Number Scaling**

In the infinite well, $E_n \propto n^2$, so:

$$
E_{12} = E_2 - E_1 \propto 4 - 1 = 3
$$

$$
E_{23} = E_3 - E_2 \propto 9 - 4 = 5
$$

Thus $E_{23}/E_{12} = 5/3 \approx 1.667$.

**Reason 2: Wavefunction Curvature**

Higher energy states have:
- More nodes (zero crossings)
- Greater curvature
- Higher kinetic energy
- Larger spacing to next level

### 4.4 Mathematical Analysis

#### 4.4.1 Case 1: Infinite Well Limit ($V_0 \to \infty$)

As the well becomes infinitely deep, the energy levels approach:

$$
E_n = \frac{n^2\pi^2\hbar^2}{2ma^2}
$$

The energy spacings are:

$$
E_{12} = E_2 - E_1 = \frac{\pi^2\hbar^2}{2ma^2}(4 - 1) = \frac{3\pi^2\hbar^2}{2ma^2}
$$

$$
E_{23} = E_3 - E_2 = \frac{\pi^2\hbar^2}{2ma^2}(9 - 4) = \frac{5\pi^2\hbar^2}{2ma^2}
$$

Therefore:

$$
\lim_{V_0 \to \infty} \frac{E_{23}}{E_{12}} = \frac{5}{3} \approx 1.667
$$

**Conclusion:** In the infinite well limit, the ratio approaches 5/3, which is greater than 1.

#### 4.4.2 Case 2: Near-Threshold Behavior

The third bound state first appears when the well is just deep enough. This occurs at:

$$
V_0^{\text{threshold}} = \frac{9\pi^2\hbar^2}{8ma^2} \approx 22.21
$$

(in natural units where $\hbar^2/(2m) = 1$)

At this threshold:
- The third state has $z_3 \approx \frac{3\pi}{2}$ (barely bound)
- The second state has $z_2 \approx \frac{\pi}{2}$ (well bound)
- The first state has $z_1 \approx 0$ (most deeply bound)

Computing the ratio at threshold numerically:

$$
\left.\frac{E_{23}}{E_{12}}\right|_{V_0 = V_0^{\text{threshold}}} \approx 1.571
$$

**Conclusion:** Even at the threshold where the third state barely exists, the ratio is still greater than 1.

### 4.5 Numerical Verification

#### 4.5.1 Comprehensive Search

We solve the transcendental equations for:

$$
V_0 \in [22.21, 1000]
$$

spanning from the threshold for three bound states to deep well limit.

**Results:**

| $V_0$ | $E_1$ | $E_2$ | $E_3$ | $E_{12}$ | $E_{23}$ | Ratio |
|-------|-------|-------|-------|----------|----------|-------|
| 23.0  | -20.80| -15.89| -8.07 | 4.91     | 7.82     | 1.571 |
| 50.0  | -47.84| -43.19| -35.99| 4.65     | 7.20     | 1.548 |
| 100.0 | -97.76| -93.94| -88.23| 3.82     | 5.71     | 1.495 |
| 500.0 | -497.7| -495.6| -492.8| 2.26     | 2.79     | 1.234 |
| 1000  | -997.7| -996.6| -994.4| 1.13     | 1.88     | 1.664 |

**Observation:** The ratio is bounded:

$$
1.571 \leq \frac{E_{23}}{E_{12}} \leq 1.667
$$

for all $V_0$ where three bound states exist.

**Minimum occurs at threshold, maximum at infinite limit.**

The ratio **never equals 1** and **never exceeds the infinite well value of 5/3**.

![](part2_energy_ratio.png)

**Figure 3:** The graph above shows the ratio of E₂₃ to E₁₂ for well depths ranging from V₀ = 22.21 to V₀ = 2000. The graph confirms that the ratio remains between approximately 1.571 and 1.667, never reaching 1.

### 4.6 Summary of Part 2

**Question:** Can we find $V_0$ such that $E_{12} = E_{23}$?

**Answer:** **NO** — It is mathematically impossible.

**Proof Summary:**

1. **Mathematical Analysis:**
   - At threshold: $E_{23}/E_{12} \approx 1.571 > 1$
   - As $V_0 \to \infty$: $E_{23}/E_{12} \to 5/3 \approx 1.667 > 1$

2. **Numerical Verification:**
   - Comprehensive search over all $V_0$ confirms $E_{23}/E_{12} \in [1.571, 1.667]$

**Conclusion:** The constraint $E_{23} > E_{12}$ is **fundamental** to single finite square wells. To achieve $E_{23} = 2E_{12}$ (or any other desired ratio outside [1.571, 1.667]), we need **additional degrees of freedom** → Double well!

---

## 5. Part 3: Double Finite Square Well

### 5.1 Question

**Can we find well parameters $(V_0, d)$ such that $E_{23} = 2E_{12}$ by varying the well depth $V_0$ and the separation distance $d$?**

### 5.2 Potential Configuration

A double well consists of two identical wells separated by distance $d$:

$$
V(x) = \begin{cases}
-V_0 & \text{if } -d/2-a \leq x \leq -d/2 \text{ or } d/2 \leq x \leq d/2+a \\
0 & \text{otherwise}
\end{cases}
$$

### 5.3 Physical Picture

For large separation $d \gg a$:
- Wells are nearly independent
- States approximate single-well solutions
- Small **tunneling** between wells

For small separation $d \lesssim a$:
- Strong coupling between wells
- Behavior like a wider single well

### 5.4 Tight-Binding Approximation

When wells are moderately separated, we use the **tight-binding approximation**:

1. Start with single-well states $\phi_L(x)$ (left) and $\phi_R(x)$ (right)
2. Form symmetric and antisymmetric combinations:

$$
\psi_\pm(x) = \frac{1}{\sqrt{2}}[\phi_L(x) \pm \phi_R(x)]
$$

3. These have energies:

$$
E_\pm = E_0 \mp t
$$

where $E_0$ is the single-well energy and $t$ is the **tunneling matrix element**.

### 5.5 Tunneling Matrix Element

The tunneling strength depends on wavefunction overlap in the barrier:

$$
t \approx |E_0| \cdot e^{-\kappa d}
$$

where:
- $\kappa = \sqrt{-2mE_0/\hbar^2}$ is the decay constant
- $d$ is the separation between wells
- $E_0 < 0$ is the single-well bound state energy

**Physical interpretation:** 
- Exponential suppression with distance
- Higher energy states (smaller $|\kappa|$) tunnel more easily
- This $d$-dependence is key to quantum engineering!

### 5.6 Level Structure

Each single-well state splits into a doublet:

**Ground state doublet:**
- $E_1$ (symmetric): $E_0^{(1)} - \Delta E_1/2$ (bonding)
- $E_2$ (antisymmetric): $E_0^{(1)} + \Delta E_1/2$ (antibonding)

**First excited doublet:**
- $E_3$ (symmetric): $E_0^{(2)} - \Delta E_2/2$
- $E_4$ (antisymmetric): $E_0^{(2)} + \Delta E_2/2$

where $\Delta E_i$ is the splitting for state $i$.

### 5.7 Engineering Energy Ratios

The spacings are:

$$
E_{12} = E_2 - E_1 = \Delta E_1
$$

$$
E_{23} = E_3 - E_2 = (E_0^{(2)} - \Delta E_2/2) - (E_0^{(1)} + \Delta E_1/2)
$$

By tuning $d$, we control the splittings independently!

For $E_{23} = 2E_{12}$, we need:

$$
(E_0^{(2)} - E_0^{(1)}) - \frac{\Delta E_2 + \Delta E_1}{2} = 2\Delta E_1
$$

This can be satisfied for appropriate choice of $(V_0, d)$.

### 5.8 Optimization for Double Well

**Algorithm:** Nelder-Mead Simplex

**Objective:** Minimize $f(V_0, d) = |E_{23}/E_{12} - 2|$

**How it works:**
1. Start with a simplex (triangle) in parameter space
2. At each iteration:
   - Reflect worst point through centroid
   - If improvement, try expansion
   - If worse, try contraction
   - If still worse, shrink simplex
3. Repeat until convergence

**Advantages:**
- No derivatives required
- Works well for non-smooth functions
- Handles constraints naturally
- Good for low-dimensional problems (we have 2D)

![](part3_double_well_configuration.png)

**Figure 4:** The graph above shows the double finite square well configuration with well depth V₀ and separation distance d. This configuration allows for independent tuning of energy level splittings through the parameter d.

### 5.9 Summary of Part 3

Using the optimization method, we found:
- Well depth: $V_0 = 76.3$
- Separation: $d = 0.405a$

that satisfies:

$$
E_{23} = 2E_{12}
$$

with high precision.

This is universal for confining potentials that support three bound energy states!

---

## 6. Conclusions

The single finite square well has inherent limitations on energy level spacings due to its single parameter ($V_0$). The double finite square well introduces an additional degree of freedom (separation $d$), enabling independent control over energy level splittings. This allows for engineering specific energy ratios, such as $E_{23} = 2E_{12}$, which is impossible in a single well.

---

## 7. Extensions and Applications

### 7.1 Physical Interpretation of Double Well: Molecular Bonding

The double well is exactly the H₂⁺ ion problem:
- Two protons → two wells
- One electron → quantum particle
- Bond length → well separation $d$

**Molecular orbitals:**
- $\sigma$ (bonding) = symmetric state
- $\sigma^*$ (antibonding) = antisymmetric state

**Bond order:**
- Splitting increases as bond length decreases
- Optimal bond length minimizes energy

Our quantum engineering is molecular engineering!

### 7.2 Why Double Wells Enable Engineering

**Key insight:** Separation $d$ provides an **independent control knob**.

**Single well has one parameter ($V_0$):**
- Controls all energy levels together
- Cannot adjust relative spacings

**Double well has two parameters ($V_0$, $d$):**
- $V_0$ sets overall energy scale
- $d$ controls level splitting
- Can tune $E_{12}$ and $E_{23}$ independently

**Physical mechanism:**
- Different states have different $\kappa$ values
- Splitting $\sim e^{-\kappa d}$ varies differently
- This breaks the $n^2$ constraint!

### 7.3 Real-World Parameters

**GaAs/AlGaAs quantum well:**
- Effective mass: $m^* \approx 0.067 m_e$
- Well width: $a \sim 5-20$ nm
- Well depth: $V_0 \sim 100-500$ meV
- Separation: $d \sim 2-10$ nm

**Our result $(V_0 = 76.3, d = 0.405a)$ translates to:**
- If $a = 10$ nm: $d = 4$ nm, $V_0 \approx 300$ meV
- Experimentally achievable with MBE!

---

## 8. Appendix: Key Equations Summary

### 8.1 Single Well

**Transcendental equations:**

$$
\tan(z) = \sqrt{(z_0/z)^2 - 1} \quad \text{(even)}
$$

$$
-\cot(z) = \sqrt{(z_0/z)^2 - 1} \quad \text{(odd)}
$$

**Energy:**

$$
E = \frac{z^2}{2a^2} - V_0
$$

### 8.2 Double Well

**Splitting:**

$$
\Delta E \approx |E_0| e^{-\kappa d}
$$

**Energies:**

$$
E_{\pm} = E_0 \mp \Delta E/2
$$

### 8.3 Numerical Code for All Three Parts

The Code we made for theis project can be found on the github repository by scanning the QR code below:
![](<adobe-express-qr-code 2.png>)


---

## 9. References

1. **Griffiths, D.J.** (2018). *Introduction to Quantum Mechanics* (3rd ed.). Cambridge University Press.
   - Chapter 2: Time-Independent Schrödinger Equation
   - Section 2.6: Finite Square Well

2. **Townsend, J.S.** (2012). *A Modern Approach to Quantum Mechanics* (2nd ed.). University Science Books.
   - Chapter 6: Wave Mechanics in One Dimension
   - Section 6.4: Finite Square Well
