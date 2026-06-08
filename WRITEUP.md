# Variable-Stiffness Gait Surface — Project Write-up

## Motivation

The UMass HRS Lab studies how people adapt their gait when the mechanical
environment changes, using variable-stiffness hardware — most directly the
AdjuSST adjustable-stiffness treadmill (Price et al., 2024), which can set belt
stiffness anywhere from about 15 to 300 kN/m. The hardware is, at its core, a
controlled second-order mechanical system: a surface with mass, stiffness, and
damping that a foot pushes against.

This project models that surface. The aim is narrow and honest: build the
second-order model the treadmill is designed around, get the dynamics right, and
use them to answer a few engineering questions. It is a dynamics/controls study
that demonstrates the relevant skill set and a real reading of the lab's work —
not a claim about human movement.

## Model

A single foot–surface contact is treated as a mass–spring–damper,

```
m·ẍ + c·ẋ + k·x = F,
```

where `x` is how far the surface deflects under load. Everything is integrated
with `ode45` on the state `[x; ẋ]` through one shared function,
`simulate_msd.m`, which the four phase scripts call. The force argument accepts
either a constant (step load) or a function handle (time-varying load), which is
all the phases need.

The standard operating point uses mid-range stiffness: `m = 50 kg`,
`k = 30 000 N/m`, `c = 1200 N·s/m`, `F = 750 N` (about one body weight). That
gives a natural frequency of 3.90 Hz, ζ = 0.49 (underdamped), and 25 mm of static
deflection.

## Phase 1 — forward problem

Apply a step load and watch the surface settle. The script reports the natural
frequency, damping ratio, and static deflection, and plots deflection vs time.
This is the baseline: given `m, k, c`, what does the surface do.

## Phase 2 — system identification

The inverse of Phase 1. Given only the response curve — as you would have from
treadmill measurements rather than from known parameters — recover the damping
ratio and natural frequency two independent ways:

- **Peak overshoot**, mapping the first overshoot through
  `Mp = exp(−πζ/√(1−ζ²))`.
- **Log decrement**, from how fast successive bounce peaks decay, plus the damped
  period for the frequency.

Both recover ζ ≈ 0.490 and ~3.9 Hz, matching the truth used to generate the
curve. This is the piece that connects the model to real hardware: it is how you
would characterise an actual surface from its response.

## Phase 3 — frequency response

A walking or running foot does not apply a step; it applies a roughly periodic
load. So the relevant question is how the surface responds across input
frequencies. The transfer function from force to deflection is

```
X(jω)/F(jω) = 1 / (k − m·ω² + j·c·ω),
```

plotted as a Bode magnitude/phase pair, with the magnitude normalised to the
static gain `1/k` so it reads directly as "how faithfully does the surface
reproduce a force at this frequency." Walking (~0.9–1.1 Hz) and running
(~1.4–1.8 Hz) stride bands are shaded on top.

The result: across the entire gait range the gain stays within about 1 dB of
unity, so the surface reproduces the stride force with little distortion. The
resonant peak is only +1.4 dB and sits at 2.8 Hz, above both stride bands — and
it is small precisely because the surface is heavily damped (ζ = 0.49). A
lightly-damped surface would ring; this one does not. (Foot-strike impacts carry
higher harmonics that reach further up the curve, which is where the damping
earns its keep, but the fundamental stride loading sits in the flat region.)

## Phase 4 — asymmetric stiffness

The lab's adaptation experiments often put one leg on a stiff surface and the
other on a compliant one. Phase 4 models exactly that: hold mass and damping
fixed, set one surface to 120 kN/m (near the top of the AdjuSST range) and the
other to 15 kN/m (near the bottom), and compare what each leg feels.

Two views:

- **Step response** — the stiff surface deflects 6.25 mm and the compliant one
  50 mm under the same load, an 8× asymmetry, with very different settling
  character (the stiff surface is faster and more lightly damped, ζ = 0.24; the
  compliant one slower and well damped, ζ = 0.69).
- **Force–deflection loop** — driven by a repeated stance load at 1 Hz, the
  reaction force `k·x + c·ẋ` is plotted against deflection over one settled
  stride. The enclosed loop area is the energy the surface takes out of each
  stride. The compliant surface dissipates roughly 60× more energy per stride
  than the stiff one (~15 J vs ~0.2 J), because its larger deflection sweeps the
  damper through a much wider stroke.

That energy and deflection asymmetry — held entirely in `k`, with `m` and `c`
untouched — is the mechanical asymmetry the two legs experience, and a clean
isolation of the variable the paradigm manipulates.

## Honest framing

This is a model of the surface, not of the walker. It reproduces the second-order
behaviour the AdjuSST hardware is built on and uses it to reason about distortion
and asymmetry. It demonstrates dynamics, system identification, frequency-domain
analysis, and clean MATLAB — and a genuine engagement with the lab's hardware —
without dressing itself up as biomechanics or motor-control research.

## Reference

Price et al. (2024), AdjuSST adjustable-stiffness treadmill, UMass HRS Lab.
