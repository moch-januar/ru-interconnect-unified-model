function rho_ref = compute_rho_ref(met, w, t)
%COMPUTE_RHO_REF Reference resistivity at T0=300 K for given geometry.
%   rho_ref = compute_rho_ref(met, w, t)
%   Implements Eq. (1)-(5) of the manuscript: FS x MS + quantum correction.
%
%   Physics:
%     Fuchs-Sondheimer surface scattering [Fuchs1938, Sondheimer1952]
%     Mayadas-Shatzkes grain-boundary scattering [Mayadas & Shatzkes, PRB 1970]
%     Quantum-confinement correction [Gall, JAP 2020, Eq. 6]
%
%   Inputs:
%     met  — scalar metal struct from codesign_params()
%     w, t — width and thickness (m), scalars or arrays of equal size
%   Output:
%     rho_ref — resistivity in Ohm*m at T0 = 300 K

% Effective conducting dimensions (subtract dead layer + barrier each side)
dead_w = met.t_dead + met.barrier;  % total lost per side in width
dead_t = met.t_dead + met.barrier;  % total lost per side in thickness
d     = max(t - 2*dead_t, 0.5e-9);  % effective thickness
w_eff = max(w - 2*dead_w, 0.5e-9);  % effective width

rho0    = met.rho0;
lambda0 = met.lambda0;

% --- Fuchs-Sondheimer for thickness direction ---
F_t = fs_factor(d, lambda0, met.p);

% --- Fuchs-Sondheimer for width direction ---
F_w = fs_factor(w_eff, lambda0, met.p);

% --- Mayadas-Shatzkes ---
F_ms = ms_factor(lambda0, met.D, met.R);

% --- Classical resistivity (Eq. 1) ---
rho_cl = rho0 .* (F_t + F_w - 1) .* F_ms;

% --- Quantum correction (Eq. 4) ---
if met.A_Q > 0
    drho_Q = met.A_Q .* (met.d_Q ./ d).^met.n_Q .* exp(-d ./ met.d_Q);
else
    drho_Q = 0;
end

% --- Full reference resistivity (Eq. 5) ---
rho_ref = rho_cl + drho_Q;
end


function F = fs_factor(dim, lambda0, p)
%FS_FACTOR Fuchs-Sondheimer scattering factor (Eq. 2).
%   F = rho_FS / rho_0 >= 1 always.

kappa = dim ./ lambda0;
F = ones(size(dim));

for k = 1:numel(dim)
    kk = kappa(k);
    if kk < 0.01
        % Very thin limit — use asymptotic expansion
        F(k) = 4 / (3 * kk * (1 - p));
    else
        % Numerical integration
        integrand = @(u) (1./u.^3 - 1./u.^5) .* ...
            (1 - exp(-kk.*u)) ./ (1 - p.*exp(-kk.*u));
        I = integral(integrand, 1, Inf, 'RelTol', 1e-10);
        F(k) = 1 / (1 - 3*(1-p)/(2*kk) * I);
    end
end

F = max(F, 1);  % physical floor
end


function F = ms_factor(lambda0, D, R)
%MS_FACTOR Mayadas-Shatzkes grain-boundary factor (Eq. 3).
%   F = rho_MS / rho_0

alpha = (lambda0 ./ D) .* R ./ (1 - R);
F = 1 ./ (1 - 1.5*alpha + 3*alpha.^2 - 3*alpha.^3 .* log(1 + 1./alpha));
F = max(F, 1);
end
