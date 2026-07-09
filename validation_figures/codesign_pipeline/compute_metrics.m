function [Rline, MTF, tau_RC, f3dB, Ea_eff] = compute_metrics(met, w, t, L, J, varargin)
%COMPUTE_METRICS Evaluate all co-design metrics at self-heated temperature.
%   [Rline, MTF, tau_RC, f3dB, Ea_eff] = compute_metrics(met, w, t, L, J)
%
%   Returns line resistance, EM MTF, RC delay, 3-dB bandwidth, and
%   effective activation energy.  All physics from Sections III-IV.
%
%   Physics:
%     Black's equation for EM MTF [Black, IEEE TED 1969]: MTF = A*J^(-n)*exp(Ea/kT)
%     Sakurai-Tamaru capacitance [Sakurai & Tamaru, IEEE TED 1983, Eq. 3]
%     Elmore RC delay: tau = 0.5*R*C*L^2
%
%   Inputs:
%     met — metal struct
%     w, t — width, thickness (m)   [scalar]
%     L    — line length (m)         [scalar]
%     J    — current density (A/m^2) [scalar or array]
%   Optional: same name-value pairs as solve_electrothermal, plus:
%     'eps_r'  — ILD relative permittivity, default 3.0
%     'h_ILD'  — ILD half-pitch spacing (m), default w
%
%   Outputs (arrays matching J):
%     Rline  — line resistance (Ohm/um)
%     MTF    — mean time to failure (hours)
%     tau_RC — RC delay (s)
%     f3dB   — 3-dB bandwidth (Hz)
%     Ea_eff — effective EM activation energy (eV)

p = inputParser;
p.KeepUnmatched = true;
p.addParameter('eps_r', 3.0, @isscalar);
p.addParameter('h_ILD', [], @(x) isscalar(x) || isempty(x));
p.parse(varargin{:});
eps_r = p.Results.eps_r;
h_ILD = p.Results.h_ILD;
if isempty(h_ILD), h_ILD = w; end  % half-pitch = width by default

% Collect remaining arguments for electrothermal solver
etArgs = [fieldnames(p.Unmatched), struct2cell(p.Unmatched)]';
etArgs = etArgs(:)';

% --- Solve electro-thermal ---
[T_line, rho_T, ~, converged] = solve_electrothermal(met, w, t, L, J, etArgs{:});

% --- Effective conducting dimensions ---
dead_w = met.t_dead + met.barrier;
dead_t = met.t_dead + met.barrier;
d     = max(t - 2*dead_t, 0.5e-9);
w_eff = max(w - 2*dead_w, 0.5e-9);

% --- Line resistance (Eq. 12) ---
Rline = rho_T ./ (w_eff * d) * 1e-6;  % Ohm/um

% --- EM activation energy (Eq. 10) ---
Ea_eff = met.Ea_bulk - met.dEa * (1/met.D + (1 - met.F001)/met.D0_em);

% --- EM MTF via Black's equation (Eq. 9) ---
k_B_eV = 8.617333e-5;  % eV/K
MTF = met.A_em .* J(:).^(-met.n_em) .* exp(Ea_eff ./ (k_B_eV .* T_line));
MTF(~converged) = 0;  % thermal runaway = immediate failure

% --- Capacitance (Eq. 13) ---
eps0 = met.const.eps0;
C_coeff = w/h_ILD + 0.77 + 1.06*(w/h_ILD)^0.25 + 1.06*(t/h_ILD)^0.5;
C_line = eps0 * eps_r * C_coeff;  % F/m

% --- RC delay (Eq. 14) ---
R_per_m = rho_T ./ (w_eff * d);  % Ohm/m
tau_RC = 0.5 .* R_per_m .* C_line .* L^2;

% --- 3-dB bandwidth (Eq. 15) ---
f3dB = 1 ./ (2 * pi .* tau_RC);

% Ensure column vectors
Rline  = Rline(:);
MTF    = MTF(:);
tau_RC = tau_RC(:);
f3dB   = f3dB(:);
end
