function [t, x, v] = simulate_msd(m, c, k, F, tspan)
% Mass-spring-damper step/forced response.
% F can be a constant (step load) or a function handle F(t) for a
% time-varying load. Returns time, deflection x, and velocity v.

if isa(F, 'function_handle')
    force = F;
else
    force = @(t) F;          % wrap a constant load as a function of time
end

eom = @(t, y) [y(2); (force(t) - c*y(2) - k*y(1))/m];
[t, y] = ode45(eom, tspan, [0; 0]);

x = y(:,1);
v = y(:,2);
end