function rho = rho_ru_helper(w, t_liner, params, metal_idx, linerType)
%RHO_RU_HELPER Simplified wrapper for rho_unified for Ru analysis
%   rho = rho_ru_helper(w, t_liner, params, metal_idx)
%   rho = rho_ru_helper(w, t_liner, params, metal_idx, linerType)
%
%   Inputs:
%     w - linewidth [m]
%     t_liner - liner thickness [m] (affects effective width)
%     params - parameter structure from params_ru_dft()
%     metal_idx - metal index (default: 1 for Ru)
%
%   Simplifies calling rho_unified with appropriate defaults for Ru

if nargin < 4
    metal_idx = 1;  % Default to Ru
end

if nargin < 5
    linerType = '';
end

% Effective width after liner
w_eff = w - 2*t_liner;
if w_eff <= 0
    rho = inf;  % Invalid geometry
    return;
end

% Extract metal structure
metal = params.metals(metal_idx);

% Extract parameters
if ~isempty(linerType)
    fp = figure_params(params, metal_idx);
    p = specularity_model(fp.delta, fp.Lambda, metal.kF, linerType, params, w_eff);
else
    p = metal.p_rough;          % Surface specularity (realistic)
end
R = metal.R0;               % Grain boundary reflection
D = w_eff;                  % Grain size ~ effective linewidth
t = w_eff;                  % Thickness ~ effective linewidth

% Call unified model with metal structure (not index)
rho = rho_unified(params, metal, w_eff, t, p, R, D, 'auto');

end
