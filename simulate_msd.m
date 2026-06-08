function [t, x, v] = simulate_msd(m, c, k, F, tspan, y0)
% Integrate the surface model m*x'' + c*x' + k*x = F.
% F is either a constant load or a function handle F(t) for time-varying input.
% tspan and y0 pass straight to ode45, so a 2-element tspan adapts the grid
% while a vector returns on that grid. Returns deflection x and velocity v.
if nargin < 6, y0 = [0; 0]; end
if ~isa(F, 'function_handle'), Fval = F; F = @(t) Fval; end

eom = @(t,y) [y(2); (F(t) - c*y(2) - k*y(1))/m];
[t, Y] = ode45(eom, tspan, y0);
x = Y(:,1);
v = Y(:,2);
end
