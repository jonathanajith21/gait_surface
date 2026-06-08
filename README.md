# Variable-Stiffness Gait Surface Simulator

A MATLAB study of walking surfaces modeled as a second-order mass-spring-damper,
motivated by the AdjuSST adjustable-stiffness treadmill (Price et al. 2024). It
builds on the two-mass spring system from MIE 124 (Lab 2), adding damping, a real
research context, and analysis beyond simulation: system identification, frequency
response, and an asymmetric-stiffness comparison. Base MATLAB, no toolboxes.

## The model

The surface is a mass `m` on a spring `k` with a damper `c`. A load `F` (a foot
pressing down) drives it through the equation of motion:

```
m*x'' + c*x' + k*x = F
```

solved with `ode45`. Stiffness values follow the AdjuSST range (15-300 kN/m).

## Files

| File | Purpose |
|------|---------|
| `simulate_msd.m` | Shared mass-spring-damper engine. Takes a constant or time-varying load, returns deflection and velocity. |
| `gait_phase_1.m` | Step response — deflection vs time; computes natural frequency, damping ratio, static deflection. |
| `gait_phase_2.m` | System identification — recovers damping ratio and natural frequency from the response shape (overshoot + log-decrement). |
| `gait_phase_3.m` | Frequency response — gain/phase across frequency, resonance, with walking and running stride bands overlaid. |
| `gait_phase_4.m` | Asymmetric stiffness — stiff vs compliant surface; per-leg deflection and force-deflection energy loop. |

## How to run

Keep all files in the same folder, set it as the MATLAB Current Folder, then run
any phase script directly (each one calls `simulate_msd`):

- `gait_phase_1.m` — step response
- `gait_phase_2.m` — system identification
- `gait_phase_3.m` — frequency response
- `gait_phase_4.m` — asymmetric-stiffness comparison

## Background

The Human Robot Systems Lab studies how people adapt their gait when surface
stiffness changes, using the AdjuSST treadmill, which is characterized as a
second-order spring-mass-damper system. This project explores those same dynamics:
how a variable-stiffness surface deflects under load, how its characteristics can
be identified from response data, how it behaves across frequency relative to gait,
and how an asymmetric setup makes each leg experience different mechanics.

It is a dynamics/controls study inspired by the lab's hardware, not a biomechanics
study of human movement.
