% Variable-stiffness gait surface - Phase 1
% Foot-ground interaction as a second-order mass-spring-damper.
% Apply a step load and look at how the surface deflects and settles.
% Stiffness range and second-order framing follow the AdjuSST treadmill
% (Price et al. 2024).

clc; clear; close all;

m = 50;          % effective surface mass (kg)
k = 30000;       % surface stiffness (N/m) - mid AdjuSST range
c = 1200;        % damping (N.s/m)
F_step = 750;    % applied load (N) ~ one body weight

wn   = sqrt(k/m);
fn   = wn/(2*pi);
zeta = c / (2*sqrt(k*m));

if zeta < 1,      kind = 'underdamped';
elseif zeta == 1, kind = 'critically damped';
else,             kind = 'overdamped';
end

fprintf('Stiffness  : %.1f kN/m\n', k/1000);
fprintf('Nat. freq  : %.2f Hz\n', fn);
fprintf('Damping    : %.2f (%s)\n', zeta, kind);
fprintf('Deflection : %.1f mm at rest\n', 1000*F_step/k);

% m*x'' + c*x' + k*x = F, solved for x''
eom = @(t,y) [y(2); (F_step - c*y(2) - k*y(1))/m];
[t, y] = ode45(eom, [0 1], [0; 0]);

x_mm = y(:,1)*1000;
x_ss = 1000*F_step/k;

figure('Position',[100 100 800 450]);
plot(t, x_mm, 'b', 'LineWidth', 2); hold on;
yline(x_ss, 'k--', 'steady state');
xlabel('Time (s)'); ylabel('Surface deflection (mm)');
title(sprintf('Step response  |  k = %.0f kN/m,  f_n = %.2f Hz,  \\zeta = %.2f', ...
              k/1000, fn, zeta));
grid on;