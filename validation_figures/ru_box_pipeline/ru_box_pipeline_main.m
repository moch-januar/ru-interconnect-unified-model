function ru_box_pipeline_main(repoRoot, manuscriptRoot, varargin)
%RU_BOX_PIPELINE_MAIN End-to-end pipeline for Ru size-effect + TCR box figures.

p = inputParser;
p.addParameter('FAST_MODE', true, @(x) islogical(x) || isnumeric(x));
p.addParameter('N_BOOT', 300, @(x) isnumeric(x) && isscalar(x) && x >= 0);
p.addParameter('RNG_SEED', 7, @(x) isnumeric(x) && isscalar(x));
p.addParameter('EXPORT_DPI', 600, @(x) isnumeric(x) && isscalar(x));
p.addParameter('N_MC', 1500, @(x) isnumeric(x) && isscalar(x) && x >= 0);
p.addParameter('USE_FULL_FS', 'auto', @(s) ischar(s) || isstring(s));
p.addParameter('DATASET', 'Ru-interconnect_rho_vs_thickness_fitted.csv', @(s) ischar(s) || isstring(s));
p.parse(varargin{:});
opt = p.Results;
opt.FAST_MODE = logical(opt.FAST_MODE);

rng(opt.RNG_SEED);

outDir = fullfile(manuscriptRoot, 'Figs');
if ~exist(outDir, 'dir'), mkdir(outDir); end

params = params_default();
metalIdx = find(strcmp({params.metals.name}, 'Ru'), 1);
if isempty(metalIdx), error('Ru metal not found in params_default().'); end
metal = params.metals(metalIdx);

raw = load_data(repoRoot, opt.DATASET);
data = preprocess(raw);

% Fit models (FS, MS, Combined) with bounds + reporting
fit = fit_models(params, metal, data, opt);

write_sanity_report(fullfile(outDir, 'SANITY_REPORT.txt'), metal, fit, data);

% Diagnostics: bootstrap CI + correlation / identifiability
if opt.FAST_MODE
    diag = diagnostics(params, metal, data, fit, opt, 'bootstrap', false);
else
    diag = diagnostics(params, metal, data, fit, opt, 'bootstrap', true);
end

% Make 2-panel box figures (strict 1x2, exactly 2 axes)
figs = make_box_figures(params, metal, data, fit, diag, opt);

% Export deterministic PDF + PNG
export_figures(figs, outDir, opt);

% TeX drop-in checklist
write_tex_checklist(outDir, figs);
end

function write_sanity_report(path, metal, fit, data)
fid = fopen(path, 'w');
if fid < 0
    warning('Could not write sanity report: %s', path);
    return;
end

fprintf(fid, 'Sanity report (Ru size-effect fits)\n');
fprintf(fid, 'Dataset: %s\n', data.sourcePath);
fprintf(fid, 'Assumed reference temperature: %g K\n', data.T_ref_K);
fprintf(fid, 'Fixed TCR alpha_TCR: %.4f 1/K\n\n', metal.alpha_TCR);

fprintf(fid, 'FS fit (rho = rho0*F_FS, film assumption: width ~ 1 um):\n');
th = fit.fs.theta;
fprintf(fid, '  rho0_300  = %.3f uOhm*cm\n', th.rho0_300*1e8);
fprintf(fid, '  lambda0   = %.2f nm\n', th.lambda0*1e9);
fprintf(fid, '  p         = %.3f\n', th.p);
fprintf(fid, '  t_dead    = %.3f nm\n', th.t_dead*1e9);
fprintf(fid, '  RMSE      = %.3f uOhm*cm\n\n', fit.fs.rmse*1e8);

fprintf(fid, 'MS-only fit (note: thickness-independent; expected to fail):\n');
th = fit.ms.theta;
fprintf(fid, '  rho0_300  = %.3f uOhm*cm\n', th.rho0_300*1e8);
fprintf(fid, '  lambda0   = %.2f nm\n', th.lambda0*1e9);
fprintf(fid, '  R         = %.3f\n', th.R);
fprintf(fid, '  D         = %.2f nm\n', th.D*1e9);
fprintf(fid, '  RMSE      = %.3f uOhm*cm\n\n', fit.ms.rmse*1e8);

fprintf(fid, 'Combined fit (rho = rho0*F_FS*F_MS; independent-scatter approximation):\n');
th = fit.combined.theta;
fprintf(fid, '  rho0_300  = %.3f uOhm*cm\n', th.rho0_300*1e8);
fprintf(fid, '  lambda0   = %.2f nm\n', th.lambda0*1e9);
fprintf(fid, '  p         = %.3f\n', th.p);
fprintf(fid, '  t_dead    = %.3f nm\n', th.t_dead*1e9);
fprintf(fid, '  R         = %.3f\n', th.R);
fprintf(fid, '  D         = %.2f nm\n', th.D*1e9);
fprintf(fid, '  RMSE      = %.3f uOhm*cm\n\n', fit.combined.rmse*1e8);

fprintf(fid, 'Model comparison:\n');
fprintf(fid, '  FS:        AIC=%.2f  BIC=%.2f\n', fit.fs.aic, fit.fs.bic);
fprintf(fid, '  MS-only:    AIC=%.2f  BIC=%.2f\n', fit.ms.aic, fit.ms.bic);
fprintf(fid, '  FSxMS:      AIC=%.2f  BIC=%.2f\n', fit.combined.aic, fit.combined.bic);

fclose(fid);
end

function write_tex_checklist(outDir, figs)
chk = fullfile(outDir, 'TEX_DROPIN_CHECKLIST.txt');
fid = fopen(chk, 'w');
if fid < 0
    warning('Could not write %s', chk);
    return;
end

fprintf(fid, 'TeX drop-in checklist (2-subplot-per-box compliance)\n');
fprintf(fid, 'Output folder: %s\n\n', outDir);

names = fieldnames(figs);
for i = 1:numel(names)
    nm = names{i};
    f = figs.(nm);
    nAxes = numel(findall(f, 'Type', 'axes'));
    fprintf(fid, '%s: axes=%d (MUST be 2)\n', nm, nAxes);
    fprintf(fid, '  PDF: Fig_%s.pdf\n', nm);
    fprintf(fid, '  PNG: Fig_%s.png\n', nm);
end

fclose(fid);
end
