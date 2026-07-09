function F = mayadas_shatzkes(lambda, D, R)
%MAYADAS_SHATZKES Grain-boundary scattering factor.
%
% Returns multiplicative factor F >= 1 such that rho = rho0 * F.
% Uses a stable closed-form approximation in terms of alpha.

lambda = max(lambda, 1e-12);
D = max(D, 1e-12);
R = min(max(R, 0), 0.999999);

alpha = (lambda ./ D) .* (R ./ max(1 - R, 1e-12));

% Handle very small alpha robustly (Taylor limit F -> 1).
F = ones(size(alpha));
mask = alpha > 1e-12;
a = alpha(mask);

den = 1 - 1.5 .* a + 3 .* a.^2 - 3 .* a.^3 .* log(1 + 1 ./ a);
F(mask) = 1 ./ den;

% Numerical safety.
F(~isfinite(F)) = 1;
F = max(F, 1.0);
end
