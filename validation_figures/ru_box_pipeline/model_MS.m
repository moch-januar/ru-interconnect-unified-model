function rho = model_MS(~, ~, geom, theta, ~)
%MODEL_MS Mayadas–Shatzkes grain-boundary scattering only.
%
% theta fields (SI units):
%   rho0_300 (Ohm*m), lambda0 (m), R (unitless), D (m)
%
% NOTE: Pure MS is geometry-independent (for fixed D, R, lambda).
% It cannot explain thickness/width trends by itself.

T = geom.T_K;

rho0_T = theta.rho0_300 .* (1 + theta.alpha_TCR .* (T - 300));
F = mayadas_shatzkes(theta.lambda0, theta.D, theta.R);
rho = rho0_T .* F;
end
