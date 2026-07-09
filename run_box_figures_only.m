function run_box_figures_only(varargin)
%RUN_BOX_FIGURES_ONLY Generate Ru box figures using the existing ru_box_pipeline.
%
% Self-contained: no external paths needed.  The bundled dataset at
%   MatlabCode/data/Ru-interconnect_rho_vs_thickness_fitted.csv
% is used automatically when no external copy is found.
%
% Usage examples:
%   run_box_figures_only                   % fully self-contained
%   run_box_figures_only('ManuscriptRoot', pwd, 'FAST_MODE', false)
%
% Output:
%   <ManuscriptRoot>/Figs/Fig_BOX_01..04.(pdf/png)

p = inputParser;
p.addParameter('RepoRoot', '', @(s) ischar(s) || isstring(s));
% Default ManuscriptRoot = MatlabCode folder so Figs/ lands next to the code.
p.addParameter('ManuscriptRoot', fileparts(mfilename('fullpath')), @(s) ischar(s) || isstring(s));
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

% Infer repo root if not provided: .../Papers.VLSI2026/Manuscript1_Transport/MatlabCode -> .../JanInterconnect
if strlength(string(opt.RepoRoot)) == 0
    here = fileparts(mfilename('fullpath'));
    % up: MatlabCode -> Manuscript1_Transport -> Papers.VLSI2026 -> JanInterconnect
    opt.RepoRoot = fileparts(fileparts(fileparts(here)));
end

repoRoot = char(opt.RepoRoot);
manuscriptRoot = char(opt.ManuscriptRoot);

if ~isfolder(manuscriptRoot)
    error('ManuscriptRoot folder not found: %s', manuscriptRoot);
end
if ~isfolder(repoRoot)
    error('RepoRoot folder not found: %s', repoRoot);
end

% Ensure this MatlabCode tree is on path.
thisRoot = fileparts(mfilename('fullpath'));
addpath(genpath(thisRoot));

% Validate core entry point exists.
entryFun = which('ru_box_pipeline_main');
if isempty(entryFun)
    error('Cannot find ru_box_pipeline_main.m on path.');
end

% Validate params_default dependency is available (supplied in config/).
if isempty(which('params_default'))
    error('params_default.m not found on path. Run: addpath(genpath(thisRoot)) first.');
end

fprintf('Running ru_box_pipeline_main...\n');
fprintf('RepoRoot      : %s\n', repoRoot);
fprintf('ManuscriptRoot: %s\n', manuscriptRoot);
fprintf('Dataset       : %s\n', char(opt.DATASET));

ru_box_pipeline_main(repoRoot, manuscriptRoot, ...
    'FAST_MODE', opt.FAST_MODE, ...
    'N_BOOT', opt.N_BOOT, ...
    'RNG_SEED', opt.RNG_SEED, ...
    'EXPORT_DPI', opt.EXPORT_DPI, ...
    'N_MC', opt.N_MC, ...
    'USE_FULL_FS', char(opt.USE_FULL_FS), ...
    'DATASET', char(opt.DATASET));

fprintf('\nDone. Exported figures are in: %s\n', fullfile(manuscriptRoot, 'Figs'));
end
