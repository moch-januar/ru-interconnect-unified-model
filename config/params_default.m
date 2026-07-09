function params = params_default()
%PARAMS_DEFAULT Minimal default parameter set for Ru box-figure pipeline.
%
% This local copy is intended to keep Manuscript1_Transport/MatlabCode
% self-contained for run_box_figures_only + ru_box_pipeline.

params = struct();

ru = struct();
ru.name = 'Ru';

% Bulk resistivity at 300 K (Ohm*m), ~7.1 uOhm*cm.
ru.rho0 = 7.1e-8;

% Effective electron mean free path at 300 K (m), order-of-magnitude value.
ru.lambda = 6.5e-9;

% Grain-boundary reflection initial guess (unitless).
ru.R0 = 0.45;

% Linear temperature coefficient of resistivity (1/K).
ru.alpha_TCR = 0.0045;

% Optional fields used by some helper code paths.
ru.wq = 0.35e-9;
ru.Aq = 1.0;
ru.A0_EM = 1.0;
ru.A0_EM_nominal = 1.0;
ru.A0_EM_tuned10yr = 1.0;

params.metals = ru;
end
