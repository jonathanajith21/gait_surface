% Variable-stiffness gait surface - Phase 3
% Frequency response of the surface: deflection per unit applied force across
% input frequencies. Normalised to the static (DC) gain so the curve reads as
% "how faithfully does the surface reproduce a force at this frequency". Walking
% and running stride bands are overlaid to see whether gait sits clear of the
% surface resonance. Mirrors the second-order frequency view in Price et al. 2024.

clc; clear; close all;

m = 50;
k = 30000;
c = 1200;

wn   = sqrt(k/m);
zeta = c/(2*sqrt(k*m));

f = logspace(-1, 1.3, 600);          % 0.1 - 20 Hz
w = 2*pi*f;
H = 1 ./ (k - m*w.^2 + 1i*c*w);      % X/F, deflection per unit force
gain_dB = 20*log10(abs(H)*k);        % normalised to DC gain 1/k
phase   = angle(H)*180/pi;

% Resonant peak of a second-order system: r = sqrt(1-2*zeta^2)
f_res   = wn*sqrt(1 - 2*zeta^2)/(2*pi);
peak_dB = 20*log10(1/(2*zeta*sqrt(1 - zeta^2)));

walk = [0.9 1.1];                    % stride frequency, walking
run  = [1.4 1.8];                    % stride frequency, running
g = @(ff) 20*log10(k ./ abs(k - m*(2*pi*ff).^2 + 1i*c*(2*pi*ff)));

fprintf('Natural freq  : %.2f Hz\n', wn/(2*pi));
fprintf('Damping ratio : %.2f\n', zeta);
fprintf('Resonant peak : %+.2f dB at %.2f Hz\n', peak_dB, f_res);
fprintf('Walking band  : %.1f-%.1f Hz -> up to %+.2f dB\n', walk, g(walk(2)));
fprintf('Running band  : %.1f-%.1f Hz -> up to %+.2f dB\n', run,  g(run(2)));

walk_col = [0.20 0.55 0.90];
run_col  = [0.90 0.45 0.20];

figure('Position',[100 100 820 620]);

subplot(2,1,1);
hw = shade_band(walk, walk_col); hold on;
hr = shade_band(run,  run_col);
hl = semilogx(f, gain_dB, 'b', 'LineWidth', 1.8);
set(gca, 'XScale', 'log');
plot(f_res, peak_dB, 'ko', 'MarkerFaceColor','k', 'HandleVisibility','off');
text(f_res*1.05, peak_dB, sprintf(' resonance %.2f Hz', f_res));
ylabel('Gain re. static (dB)');
title('Phase 3: surface frequency response with gait bands');
legend([hl hw hr], {'surface','walking','running'}, 'Location','northwest');
ylim([-35 5]); grid on;

subplot(2,1,2);
shade_band(walk, walk_col); hold on;
shade_band(run,  run_col);
semilogx(f, phase, 'b', 'LineWidth', 1.8);
set(gca, 'XScale', 'log');
xlabel('Frequency (Hz)'); ylabel('Phase (deg)');
ylim([-180 0]); grid on;

function h = shade_band(band, col)
yl = [-200 200];                     % drawn tall, axis limits clip it
h = patch([band(1) band(2) band(2) band(1)], [yl(1) yl(1) yl(2) yl(2)], ...
          col, 'FaceAlpha', 0.15, 'EdgeColor', 'none');
end
