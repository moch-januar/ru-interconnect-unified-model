function F = fuchs_sondheimer(w_eff, t_eff, lambda, p)
%FUCHS_SONDHEIMER Approximate FS size-effect factor for rectangular wires.
%
% F >= 1 multiplies bulk resistivity.
% Uses a first-order compact approximation suitable for fitting workflows.

% Guard against non-physical values.
minDim = 0.25e-9;
w_eff = max(w_eff, minDim);
t_eff = max(t_eff, minDim);
lambda = max(lambda, 1e-12);
p = min(max(p, 0), 0.999999);

eta_w = lambda ./ w_eff;
eta_t = lambda ./ t_eff;

% First-order FS correction; additive width + thickness contributions.
F = 1 + (3/8) * (1 - p) .* (eta_w + eta_t);

% Keep strictly physical floor.
F = max(F, 1.0);
end
