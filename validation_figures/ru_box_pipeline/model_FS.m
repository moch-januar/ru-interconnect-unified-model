function rho = model_FS(params, metal, geom, theta, opt)
%MODEL_FS Fuchs–Sondheimer size-effect + dead-layer effective thickness.
%
% theta fields (SI units):
%   rho0_300 (Ohm*m), lambda0 (m), p (unitless), t_dead (m)

arguments
    params
    metal
    geom struct
    theta struct
    opt struct
end

w = geom.w_m;
t = geom.t_m;
T = geom.T_K;

[t_eff, w_eff] = effective_dims(w, t, theta.t_dead);

% Bulk temperature dependence
rho0_T = rho_bulk_T(theta.rho0_300, theta.alpha_TCR, T, 300);

% Mean free path temperature dependence: two options
% opt.lambda_T_mode: 'const' or 'inv_rho0'
if isfield(opt, 'lambda_T_mode')
    mode = opt.lambda_T_mode;
else
    mode = 'const';
end

switch lower(string(mode))
    case "const"
        lambda_T = theta.lambda0 * ones(size(T));
    case "inv_rho0"
        rho0_300 = theta.rho0_300;
        lambda_T = theta.lambda0 .* (rho0_300 ./ rho0_T);
    otherwise
        error('Unknown lambda_T_mode: %s', mode);
end

% FS factor
F = zeros(size(T));
for i = 1:numel(T)
    F(i) = fuchs_sondheimer(w_eff(i), t_eff(i), lambda_T(i), theta.p);
end

rho = rho0_T .* F;
end

function [t_eff, w_eff] = effective_dims(w, t, t_dead)
% Ensure physically constrained effective dimensions.
minDim = 0.25e-9;

t_eff = max(t - 2*t_dead, minDim);
w_eff = max(w - 2*t_dead, minDim);
end

function rho0_T = rho_bulk_T(rho0_300, alpha_TCR, T, T0)
% Linear TCR model, appropriate for modest T range.
rho0_T = rho0_300 .* (1 + alpha_TCR .* (T - T0));
end
