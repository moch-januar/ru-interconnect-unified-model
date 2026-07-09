function fit = fit_models(params, metal, data, opt)
%FIT_MODELS Constrained fits for FS, MS, and Combined models.

% Bounds (physically constrained)
b = bounds_default(metal);

% Shared fixed values
alpha_TCR = metal.alpha_TCR;

% Geometry at 300K (this dataset is effectively isothermal)
geom300 = struct('w_m', data.w_m, 't_m', data.t_m, 'T_K', data.T_ref_K * ones(size(data.t_m)));

y_obs = data.rho_ohmm;

% ---------- FS-only fit (identifiable on thickness data) ----------
par0_fs = struct(...
    'rho0_300', metal.rho0, ...
    'lambda0', metal.lambda, ...
    'p', 0.4, ...
    't_dead', 0.2e-9, ...
    'alpha_TCR', alpha_TCR);

fit.fs = solve_fit(@(th) model_FS(params, metal, geom300, th, struct('lambda_T_mode','const')), ...
    par0_fs, b.fs, y_obs);

% ---------- MS-only fit (will be poor on thickness-only data) ----------
par0_ms = struct(...
    'rho0_300', metal.rho0, ...
    'lambda0', metal.lambda, ...
    'R', metal.R0, ...
    'D', 30e-9, ...
    'alpha_TCR', alpha_TCR);

fit.ms = solve_fit(@(th) model_MS(params, metal, geom300, th, struct()), ...
    par0_ms, b.ms, y_obs);

% ---------- Combined fit ----------
par0_c = struct(...
    'rho0_300', metal.rho0, ...
    'lambda0', metal.lambda, ...
    'p', 0.4, ...
    't_dead', 0.2e-9, ...
    'R', metal.R0, ...
    'D', 30e-9, ...
    'alpha_TCR', alpha_TCR);

fit.combined = solve_fit(@(th) model_combined(params, metal, geom300, th, struct('lambda_T_mode','const', 'use_full_fs', opt.USE_FULL_FS)), ...
    par0_c, b.combined, y_obs);

% Scoring
fit = add_scores(fit, y_obs);

% Sanity report
fit.sanity = sanity_report(metal, fit, b, data);
end

function rho = model_combined(params, metal, geom, theta, opt)
% Combined independent-scatter approximation: rho = rho0(T)*F_FS*F_MS.

rho_fs = model_FS(params, metal, geom, theta, opt);
F_ms = mayadas_shatzkes(theta.lambda0, theta.D, theta.R);

% Remove rho0(T) already included in model_FS, so apply MS as multiplicative factor
rho = rho_fs .* F_ms;
end

function b = bounds_default(metal)
% Bounds chosen to be physically plausible for Ru BEOL.

b = struct();

b.common.rho0_300 = [5.5e-8, 1.1e-7];
b.common.lambda0  = [1e-9, 30e-9];
b.common.p        = [0.0, 0.95];
b.common.t_dead   = [0.0, 2.0e-9];
b.common.R        = [0.0, 0.7];
b.common.D        = [5e-9, 120e-9];
b.common.alpha_TCR = [0.002, 0.006];

b.fs = struct('rho0_300', b.common.rho0_300, 'lambda0', b.common.lambda0, 'p', b.common.p, 't_dead', b.common.t_dead);
b.ms = struct('rho0_300', b.common.rho0_300, 'lambda0', b.common.lambda0, 'R', b.common.R, 'D', b.common.D);
b.combined = struct('rho0_300', b.common.rho0_300, 'lambda0', b.common.lambda0, 'p', b.common.p, 't_dead', b.common.t_dead, 'R', b.common.R, 'D', b.common.D);

% Use metal as soft prior by narrowing initial guesses only (not bounds).
if isfield(metal, 'alpha_TCR')
    % alpha_TCR is fixed in this pipeline (no temperature-dependent data)
end
end

function sol = solve_fit(modelFun, theta0, bounds, y_obs)
% Constrained least squares via fminsearch + bound transform.

names = fieldnames(bounds);
lb = zeros(numel(names),1);
ub = zeros(numel(names),1);
x0 = zeros(numel(names),1);
for i = 1:numel(names)
    nm = names{i};
    lim = bounds.(nm);
    lb(i) = lim(1);
    ub(i) = lim(2);
    x0(i) = theta0.(nm);
end

z0 = inv_sigmoid((x0 - lb) ./ (ub - lb));

obj = @(z) sse(modelFun, z_to_theta(z, names, lb, ub, theta0), y_obs);

opts = optimset('Display','off', 'MaxIter', 5e4, 'MaxFunEvals', 1e5);
[z_opt, fval] = fminsearch(obj, z0, opts);

theta_opt = z_to_theta(z_opt, names, lb, ub, theta0);

y_hat = modelFun(theta_opt);
res = y_hat - y_obs;

sol = struct();
sol.theta = theta_opt;
sol.names = names;
sol.lb = lb;
sol.ub = ub;
sol.z_opt = z_opt;
sol.sse = fval;
sol.rmse = sqrt(mean(res.^2));
sol.residuals = res;
sol.y_hat = y_hat;
end

function theta = z_to_theta(z, names, lb, ub, thetaTemplate)
% Map unconstrained z -> bounded x via sigmoid.

x01 = sigmoid(z);
x = lb + (ub - lb) .* x01;
theta = thetaTemplate;
for i = 1:numel(names)
    theta.(names{i}) = x(i);
end
end

function val = sse(modelFun, theta, y_obs)
y = modelFun(theta);
r = y - y_obs;
val = sum(r.^2);
if ~isfinite(val)
    val = realmax/10;
end
end

function y = sigmoid(z)
y = 1 ./ (1 + exp(-z));
end

function z = inv_sigmoid(y)
y = min(max(y, 1e-6), 1-1e-6);
z = log(y ./ (1-y));
end

function fit = add_scores(fit, y_obs)
models = {'fs','ms','combined'};
N = numel(y_obs);
for i = 1:numel(models)
    m = models{i};
    k = numel(fit.(m).names);
    sse = fit.(m).sse;
    aic = N*log(sse/N) + 2*k;
    bic = N*log(sse/N) + k*log(N);
    fit.(m).aic = aic;
    fit.(m).bic = bic;
end
end

function sanity = sanity_report(metal, fit, b, data)
% Minimal sanity table for reviewer-grade plausibility.

sanity = struct();
sanity.source = data.sourcePath;

sanity.bounds = b.common;

sanity.fs = fit.fs.theta;
sanity.ms = fit.ms.theta;
sanity.combined = fit.combined.theta;

sanity.fixed.alpha_TCR = metal.alpha_TCR;
sanity.fixed.T_ref_K = data.T_ref_K;
end
