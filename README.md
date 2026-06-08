# Variable-Stiffness Gait Surface Simulator

A small MATLAB study of the second-order dynamics behind a variable-stiffness
walking surface, modelled as a mass–spring–damper. It is motivated by the
**AdjuSST** adjustable-stiffness treadmill from the UMass Human Robotics Systems
Lab (Price et al., 2024), whose belt stiffness is tunable over roughly
15–300 kN/m.

**What this is:** a dynamics / controls / MATLAB exercise that reproduces the
second-order behaviour the AdjuSST hardware is built around, and uses it to ask
a few engineering questions (does the surface distort the gait input? what does
each leg feel under asymmetric stiffness?).

**What this is not:** it is not biomechanics, motor-control, or neuroscience
research. There is no human-movement data here — only the surface model. The
gait frequencies are used as input bands, nothing more.

## Model

Foot–surface interaction as a single degree of freedom:

```
m·ẍ + c·ẋ + k·x = F
```

with `x` the surface deflection. Solved with `ode45` on the state `[x; ẋ]`.

Standard parameters (mid-range AdjuSST stiffness):

| symbol | value | meaning |
|--------|-------|---------|
| `m` | 50 kg | effective surface mass |
| `k` | 30 000 N/m | stiffness |
| `c` | 1200 N·s/m | damping |
| `F` | 750 N | applied load (~one body weight) |

These give a natural frequency of **3.90 Hz**, damping ratio **ζ = 0.49**
(underdamped), and a static deflection of **25 mm**.

## Phases

All four phases share one integrator, `simulate_msd.m`.

- **Phase 1 — `gait_phase_1.m`** — step response. The forward problem
  (`m, k, c → behaviour`): natural frequency, damping ratio, static deflection,
  and the deflection-vs-time curve.

- **Phase 2 — `gait_phase_2.m`** — system identification. The backward problem
  (`behaviour → m, k, c`): recover ζ and frequency from the response shape alone,
  via peak overshoot and log decrement. Both recover ζ ≈ 0.49 and ~3.9 Hz.

- **Phase 3 — `gait_phase_3.m`** — frequency response. Bode magnitude/phase of
  deflection-per-force, normalised to the static gain, with walking
  (~0.9–1.1 Hz) and running (~1.4–1.8 Hz) stride bands overlaid. Across the whole
  gait range the gain stays under ~1 dB, so the surface reproduces the gait force
  faithfully; the resonant peak (+1.4 dB at 2.8 Hz) sits above the stride bands,
  kept small by the deliberately high damping.

- **Phase 4 — `gait_phase_4.m`** — asymmetric stiffness. A stiff surface
  (120 kN/m) under one leg and a compliant one (15 kN/m) under the other — the
  asymmetric-stiffness paradigm the lab uses to drive gait adaptation. Same mass
  and damping, only `k` changes. The legs feel an 8× difference in peak deflection
  (6 mm vs 50 mm) and roughly 60× difference in energy the surface removes per
  stride (~0.2 J vs ~15 J).

## Running

Base MATLAB, no toolboxes. From this directory:

```matlab
gait_phase_1
gait_phase_2
gait_phase_3
gait_phase_4
```

Each script prints a short summary and draws one figure.

## Reference

Price et al. (2024), AdjuSST adjustable-stiffness treadmill, UMass HRS Lab.
