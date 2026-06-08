% Variable-stiffness gait surface - Phase 2
% Recover damping ratio and natural frequency from the response shape
% alone, the way you would from measured treadmill data rather than from
% known m, k, c. Follows the second-order characterization in Price et al. 2024.

clc; clear; close all;

m = 50;
k = 30000;
c = 1200;
F_step = 750;

wn_true   = sqrt(k/m);
zeta_true = c/(2*sqrt(k*m));

[t, x] = simulate_msd(m, c, k, F_step, linspace(0,1,2000));   % fixed grid for clean peak-finding
x_ss = F_step/k;

% Method 1: peak overshoot maps to damping via Mp = exp(-pi*z/sqrt(1-z^2))
[x_peak, i_peak] = max(x);
Mp = (x_peak - x_ss)/x_ss;
lnMp    = log(Mp);
zeta_Mp = -lnMp / sqrt(pi^2 + lnMp^2);

% Method 2: log decrement - how fast successive bounce peaks shrink
pk_val = []; pk_t = [];
for i = 2:length(x)-1
    if x(i) > x(i-1) && x(i) > x(i+1)
        pk_val(end+1) = x(i); %#ok<SAGROW>
        pk_t(end+1)   = t(i); %#ok<SAGROW>
    end
end
a1 = pk_val(1) - x_ss;
a2 = pk_val(2) - x_ss;
delta   = log(a1/a2);
zeta_ld = delta / sqrt(4*pi^2 + delta^2);
Td      = pk_t(2) - pk_t(1);                       % damped period
wn_ld   = (2*pi/Td) / sqrt(1 - zeta_ld^2);

fprintf('                     true     overshoot   log-dec\n');
fprintf('Damping ratio   : %7.3f   %7.3f   %7.3f\n', zeta_true, zeta_Mp, zeta_ld);
fprintf('Nat freq (rad/s): %7.2f       -       %7.2f\n', wn_true, wn_ld);
fprintf('Nat freq (Hz)   : %7.2f       -       %7.2f\n', wn_true/(2*pi), wn_ld/(2*pi));

figure('Position',[100 100 850 480]);
plot(t, x*1000, 'b', 'LineWidth', 1.8); hold on;
yline(x_ss*1000, 'k--', 'steady state');
plot(t(i_peak), x_peak*1000, 'ro', 'MarkerFaceColor','r');
text(t(i_peak), x_peak*1000+0.6, sprintf('  overshoot %.0f%%', Mp*100), 'Color','r');
plot(pk_t(1:min(3,end)), pk_val(1:min(3,end))*1000, 'ks', ...
    'MarkerFaceColor','y', 'MarkerSize',8);
xlabel('Time (s)'); ylabel('Surface deflection (mm)');
title('Phase 2: identifying damping and frequency from the response');
grid on;