% Variable-stiffness gait surface - Phase 4
% Asymmetric stiffness: a stiff surface under one leg, a compliant surface under
% the other - the asymmetric-stiffness paradigm the lab uses to drive gait
% adaptation. Same mass and damping; only k changes. Compare what each leg feels:
% peak deflection under a step load, and the force-deflection loop under a
% repeated stance load (loop area = energy the surface pulls out of each stride).

clc; clear; close all;

m = 50;
c = 1200;
F_step = 750;

surf = struct('name', {'stiff','compliant'}, ...
    'k',    {120000, 15000}, ...          % top / bottom of AdjuSST range
    'col',  {[0.20 0.30 0.80], [0.85 0.35 0.20]});

f_gait = 1.0;                                        % stride frequency (Hz), walking
T  = 1/f_gait;
nC = 8;                                              % run several strides to steady state
Fload = @(t) F_step/2*(1 - cos(2*pi*f_gait*t));      % 0..F_step, one loading cycle per stride

figure('Position',[100 100 980 440]);

fprintf('%-10s %8s %7s %6s %9s %10s\n', ...
    'surface','k(kN/m)','fn(Hz)','zeta','defl(mm)','E(J/strd)');
for s = surf
    wn = sqrt(s.k/m); zeta = c/(2*sqrt(s.k*m));

    [ts, xs] = simulate_msd(m, c, s.k, F_step, [0 1]);

    [tg, xg, vg] = simulate_msd(m, c, s.k, Fload, linspace(0, nC*T, 4000));
    R    = s.k*xg + c*vg;                            % reaction force felt at the foot
    last = tg >= (nC-1)*T;                           % keep the final, settled stride
    E    = trapz(tg(last), c*vg(last).^2);           % energy the damper removes per stride

    fprintf('%-10s %8.0f %7.2f %6.2f %9.1f %10.2f\n', ...
        s.name, s.k/1000, wn/(2*pi), zeta, 1000*F_step/s.k, E);

    subplot(1,2,1); hold on;
    plot(ts, xs*1000, 'Color', s.col, 'LineWidth', 1.8, 'DisplayName', s.name);

    subplot(1,2,2); hold on;
    plot(xg(last)*1000, R(last), 'Color', s.col, 'LineWidth', 1.8, 'DisplayName', s.name);
end

subplot(1,2,1);
xlabel('Time (s)'); ylabel('Deflection (mm)');
title('Step response per leg'); legend('Location','southeast'); grid on;

subplot(1,2,2);
xlabel('Deflection (mm)'); ylabel('Reaction force (N)');
title('Force-deflection loop, one stride'); legend('Location','northwest'); grid on;