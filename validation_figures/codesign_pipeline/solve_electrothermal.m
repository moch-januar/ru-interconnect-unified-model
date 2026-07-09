function [T_line, rho_T, DT, converged] = solve_electrothermal(met, w, t, L, J, varargin)
%SOLVE_ELECTROTHERMAL Self-consistent electro-thermal solver (Sec. III).
%   [T_line, rho_T, DT, converged] = solve_electrothermal(met, w, t, L, J)
%
%   Iteratively solves the coupled rho(T) <-> DeltaT(rho) system
%   (Eq. 6-11 of the manuscript) until convergence.
%
%   Physics:
%     Linear TCR with size-corrected alpha [Sondheimer1952: alpha_eff = alpha*rho0/rho_ref]
%     Joule self-heating with longitudinal + vertical heat paths
%     Wiedemann-Franz thermal conductivity: k_metal = L0*T/rho [standard]
%     Damped Picard iteration for convergence stability
%
%   Inputs:
%     met — metal struct from codesign_params()
%     w, t — width, thickness (m)  [scalar]
%     L    — line length (m)       [scalar]
%     J    — current density (A/m^2) [scalar or array]
%   Optional name-value:
%     'T0'       — ambient temperature (K), default 300
%     'MaxIter'  — max iterations, default 200
%     'Tol'      — convergence tolerance (K), default 0.01
%     'kILD'     — ILD thermal conductivity (W/m/K), default 1.0
%     'A_ILD'    — ILD cross-sectional area (m^2), default (50e-9)^2
%
%   Outputs:
%     T_line    — self-heated line temperature (K)
%     rho_T     — resistivity at T_line (Ohm*m)
%     DT        — temperature rise Delta T (K)
%     converged — logical flag (true if converged)

p = inputParser;
p.addParameter('T0', 300, @isscalar);
p.addParameter('MaxIter', 200, @isscalar);
p.addParameter('Tol', 0.01, @isscalar);
p.addParameter('kILD', 1.0, @isscalar);
p.addParameter('A_ILD', (50e-9)^2, @isscalar);
p.parse(varargin{:});
T0      = p.Results.T0;
maxIter = p.Results.MaxIter;
tol     = p.Results.Tol;
kILD    = p.Results.kILD;
A_ILD   = p.Results.A_ILD;

% Pre-compute reference resistivity at T0
rho_ref = compute_rho_ref(met, w, t);

% Size-corrected TCR (Eq. 7)
alpha_eff = met.alpha_TCR * met.rho0 / rho_ref;

% Metal cross-section
A_met = w * t;

% Effective conducting dimensions for Wiedemann-Franz
dead_w = met.t_dead + met.barrier;
dead_t = met.t_dead + met.barrier;
d     = max(t - 2*dead_t, 0.5e-9);
w_eff = max(w - 2*dead_w, 0.5e-9);

L0 = met.const.L0;  % Lorenz number

nJ = numel(J);
T_line    = zeros(nJ, 1);
rho_T     = zeros(nJ, 1);
DT        = zeros(nJ, 1);
converged = true(nJ, 1);

for jj = 1:nJ
    Jcur = J(jj);
    T_k  = T0;
    conv = false;

    for iter = 1:maxIter
        % Resistivity at current T (Eq. 6)
        rho_k = rho_ref * (1 + alpha_eff * (T_k - T0));

        % Wiedemann-Franz thermal conductivity of metal (Eq. 9)
        kRu = L0 * T_k / rho_k;

        % Effective longitudinal thermal conductivity (Eq. 8)
        k_eff = kRu * A_met / (A_met + A_ILD) + kILD * A_ILD / (A_met + A_ILD);

        % Temperature rise (Eq. 7 in manuscript)
        DT_long = Jcur^2 * rho_k * L^2 / (8 * k_eff);
        DT_vert = Jcur^2 * rho_k * t / (2 * kILD) * (w/2);
        DT_new  = DT_long + DT_vert;

        T_new = T0 + DT_new;

        if abs(T_new - T_k) < tol
            conv = true;
            T_k  = T_new;
            break;
        end

        % Damped update for stability at high J
        T_k = 0.5 * T_k + 0.5 * T_new;
    end

    if ~conv
        % Mark as thermal runaway
        converged(jj) = false;
    end

    T_line(jj) = T_k;
    rho_T(jj)  = rho_ref * (1 + alpha_eff * (T_k - T0));
    DT(jj)     = T_k - T0;
end
end
