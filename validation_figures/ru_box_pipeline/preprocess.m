function data = preprocess(raw)
%PREPROCESS Clean and standardize the dataset.

th = raw.thickness_nm(:);
rho_u = raw.rho_uohmcm(:);

mask = isfinite(th) & isfinite(rho_u) & th > 0 & rho_u > 0;
th = th(mask);
rho_u = rho_u(mask);

[th, order] = sort(th);
rho_u = rho_u(order);

% Store in SI
nm = 1e-9;
data = struct();
data.thickness_nm = th;
data.t_m = th * nm;

% This dataset behaves like a thickness-dependent film resistivity curve.
% Model convention: treat width as effectively infinite so FS is thickness-dominated.
data.w_m = ones(size(data.t_m)) * 1e-6; % 1 micron

% Resistivity
uohmcm_to_ohmm = 1e-8;
data.rho_uohmcm = rho_u;
data.rho_ohmm = rho_u * uohmcm_to_ohmm;

% Temperature grid used for BOX_01 (sensitivity study)
data.T_grid_K = (250:10:450)';
data.T_ref_K = 300;

% Metadata
if isfield(raw, 'sourcePath'), data.sourcePath = raw.sourcePath; end
if isfield(raw, 'meta'), data.meta = raw.meta; end
end
