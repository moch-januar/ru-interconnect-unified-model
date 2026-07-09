function diag = diagnostics(params, metal, data, fit, opt, varargin)
%DIAGNOSTICS Bootstrap CI + identifiability (Jacobian-based correlation).

p = inputParser;
p.addParameter('bootstrap', false, @(x) islogical(x) || isnumeric(x));
p.parse(varargin{:});
doBoot = logical(p.Results.bootstrap);

geom300 = struct('w_m', data.w_m, 't_m', data.t_m, 'T_K', data.T_ref_K * ones(size(data.t_m)));
y_obs = data.rho_ohmm;

% Use combined model for identifiability reporting (worst-case correlations)
modelFun = @(th) local_model_combined(params, metal, geom300, th, opt);
sol = fit.combined;

diag = struct();

% Jacobian (finite difference w.r.t. physical parameters, not z)
[names, x0] = theta_to_vector(sol.theta, sol.names);
J = finite_jacobian_theta(@(x) modelFun(vector_to_theta(x, sol.theta, sol.names)), x0);

r = sol.y_hat - y_obs;
N = numel(r);
P = numel(names);
sse = sum(r.^2);
sigma2 = sse / max(N - P, 1);

JTJ = J.' * J;
if rcond(JTJ) < 1e-12
    Cov = nan(P);
else
    Cov = inv(JTJ) * sigma2;
end

corr = Cov;
if all(isfinite(Cov(:)))
    d = sqrt(diag(Cov));
    corr = Cov ./ (d*d.');
end

diag.identifiability = struct();
diag.identifiability.names = names;
diag.identifiability.J = J;
diag.identifiability.Cov = Cov;
diag.identifiability.Corr = corr;

% Monte Carlo prediction band for rho(thickness) using covariance (if available)
diag.mc = monte_carlo_band(params, metal, data, fit, diag, opt);

% Bootstrap confidence intervals (combined model)
if doBoot && opt.N_BOOT > 0
    diag.bootstrap = bootstrap_params(params, metal, data, opt, opt.N_BOOT);
else
    diag.bootstrap = struct('enabled', false);
end

% Temperature sensitivity (two lambda(T) assumptions)
diag.temp = temperature_sensitivity(params, metal, fit, data, opt);
end

function [names, thetaTemplate, lb, ub, z0] = pack_theta(theta, names, lb, ub, z0)
% pass-through helper to keep signature explicit
% thetaTemplate must carry alpha_TCR (fixed)

thetaTemplate = theta;
end

function [names, x0] = theta_to_vector(theta, names)
x0 = zeros(numel(names), 1);
for i = 1:numel(names)
    x0(i) = theta.(names{i});
end
end

function theta = vector_to_theta(x, thetaTemplate, names)
theta = thetaTemplate;
for i = 1:numel(names)
    theta.(names{i}) = x(i);
end
end

function J = finite_jacobian_theta(yFun, x0)
% Central-difference Jacobian of model output w.r.t. physical parameters x.

f0 = yFun(x0);
N = numel(f0);
P = numel(x0);
J = zeros(N, P);

for i = 1:P
    xi = x0(i);
    dx = max(1e-12, 1e-3*abs(xi));
    xp = x0; xm = x0;
    xp(i) = xi + dx;
    xm(i) = xi - dx;
    fp = yFun(xp);
    fm = yFun(xm);
    J(:,i) = (fp - fm) / (2*dx);
end
end

function out = bootstrap_params(params, metal, data, opt, nBoot)
% Nonparametric bootstrap on thickness-resistivity points.

out = struct();
out.enabled = true;
out.nBoot = nBoot;

N = numel(data.t_m);
idx = randi(N, [N, nBoot]);

thetaBoot = nan(nBoot, 6);
nameOrder = {'rho0_300','lambda0','p','t_dead','R','D'};

for b = 1:nBoot
    ii = idx(:,b);
    sub = data;
    sub.t_m = data.t_m(ii);
    sub.w_m = data.w_m(ii);
    sub.rho_ohmm = data.rho_ohmm(ii);
    sub.rho_uohmcm = data.rho_uohmcm(ii);

    fitB = fit_models(params, metal, sub, opt);
    th = fitB.combined.theta;
    thetaBoot(b,:) = [th.rho0_300, th.lambda0, th.p, th.t_dead, th.R, th.D];
end

out.nameOrder = nameOrder;
out.thetaBoot = thetaBoot;
out.ci95 = prctile(thetaBoot, [2.5 97.5]);
end

function temp = temperature_sensitivity(params, metal, fit, data, opt)
% Two interpretations for temperature dependence of size-effect terms.

T = data.T_grid_K;
geomT = struct('w_m', 1e-6*ones(size(T)), 't_m', 10e-9*ones(size(T)), 'T_K', T);

theta = fit.combined.theta;
% Add fixed alpha_TCR
if ~isfield(theta, 'alpha_TCR'), theta.alpha_TCR = metal.alpha_TCR; end

rho_const = model_FS(params, metal, geomT, theta, struct('lambda_T_mode','const')) .* mayadas_shatzkes(theta.lambda0, theta.D, theta.R);
rho_inv   = model_FS(params, metal, geomT, theta, struct('lambda_T_mode','inv_rho0')) .* mayadas_shatzkes(theta.lambda0, theta.D, theta.R);

% "Data" proxy: anchored at 300K thickness-fit point, linear TCR only
rho300 = interp1(data.thickness_nm, data.rho_uohmcm, 10, 'linear', 'extrap') * 1e-8;
rho_data_proxy = rho300 .* (1 + metal.alpha_TCR * (T - 300));

temp = struct();
temp.T = T;
temp.rho_const = rho_const;
temp.rho_inv = rho_inv;
temp.rho_data_proxy = rho_data_proxy;
end

function rho = local_model_combined(params, metal, geom, theta, opt)
% Keep combined model consistent with fit.

rho_fs = model_FS(params, metal, geom, theta, struct('lambda_T_mode','const'));
F_ms = mayadas_shatzkes(theta.lambda0, theta.D, theta.R);
rho = rho_fs .* F_ms;
end

function mc = monte_carlo_band(params, metal, data, fit, diag, opt)
%MONTE_CARLO_BAND Draw parameter samples and compute prediction band.
% This is not a substitute for measurement uncertainty; it's a parameter-uncertainty
% propagation to expose how underconstrained the fit is.

mc = struct();
mc.enabled = false;

if ~isfield(opt, 'N_MC') || opt.N_MC <= 0
    return;
end

names = fit.combined.names;
thetaHat = fit.combined.theta;

if ~isfield(diag, 'identifiability') || ~isfield(diag.identifiability, 'Cov')
    return;
end

Cov = diag.identifiability.Cov;
if any(~isfinite(Cov(:)))
    return;
end

% Build mean vector in the same order as names
mu = zeros(numel(names),1);
for i = 1:numel(names)
    mu(i) = thetaHat.(names{i});
end

% Draw samples (truncate by bounds from the original fit)
lb = fit.combined.lb;
ub = fit.combined.ub;

% Cholesky with jitter
S = (Cov + Cov.')/2;
S = S + eye(size(S))*max(1e-30, 1e-12*trace(S)/max(size(S,1),1));

R = chol(S, 'lower');
Z = randn(numel(names), opt.N_MC);
X = mu + R*Z;

% Clip to bounds (crude but prevents nonsense)
for i = 1:numel(names)
    X(i,:) = min(max(X(i,:), lb(i)), ub(i));
end

geom300 = struct('w_m', data.w_m, 't_m', data.t_m, 'T_K', data.T_ref_K * ones(size(data.t_m)));

Y = nan(numel(data.t_m), opt.N_MC);
for k = 1:opt.N_MC
    th = thetaHat;
    for i = 1:numel(names)
        th.(names{i}) = X(i,k);
    end
    th.alpha_TCR = metal.alpha_TCR;
    rho = model_FS(params, metal, geom300, th, struct('lambda_T_mode','const')) .* mayadas_shatzkes(th.lambda0, th.D, th.R);
    Y(:,k) = rho;
end

mc.enabled = true;
mc.rho_p05 = prctile(Y, 5, 2);
mc.rho_p95 = prctile(Y, 95, 2);
mc.rho_med = prctile(Y, 50, 2);
end
