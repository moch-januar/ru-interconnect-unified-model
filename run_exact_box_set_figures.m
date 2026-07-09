function run_exact_box_set_figures(varargin)
%RUN_EXACT_BOX_SET_FIGURES Generate the full Box/Validation figure set locally.
%
% This launcher reproduces the figure families shown in your attached images:
%   - Ru box pipeline figures (Fig_BOX_01..04)
%   - Validation figures (condition number, LOOCV, correlation, sensitivity, literature)
%   - Co-design box figures (Fig_BOX_26..30 + node_table.tex)
%
% Outputs are written to:
%   Manuscript1_Transport/MatlabCode/Figs

p = inputParser;
p.addParameter('FAST_MODE', true, @(x) islogical(x) || isnumeric(x));
p.addParameter('N_BOOT', 300, @(x) isnumeric(x) && isscalar(x) && x >= 0);
p.addParameter('N_MC', 1500, @(x) isnumeric(x) && isscalar(x) && x >= 0);
p.parse(varargin{:});
opt = p.Results;

thisRoot = fileparts(mfilename('fullpath'));
outDir = fullfile(thisRoot, 'Figs');
if ~exist(outDir, 'dir')
    mkdir(outDir);
end

addpath(genpath(thisRoot));

fprintf('=== Full Box Set Figure Generation ===\n');
fprintf('Root   : %s\n', thisRoot);
fprintf('Output : %s\n\n', outDir);

% % 1) Ru strict 1x2 box set (BOX_01..04)
% fprintf('[1/3] Running Ru box pipeline (BOX_01..04)...\n');
% run_box_figures_only('ManuscriptRoot', thisRoot, ...
%     'FAST_MODE', logical(opt.FAST_MODE), ...
%     'N_BOOT', opt.N_BOOT, ...
%     'N_MC', opt.N_MC);
% fprintf('  Done.\n\n');

% 2) Validation figures (Fisher/LOOCV/Correlation/Sensitivity/Literature)
fprintf('[2/3] Running validation figures...\n');
run(fullfile(thisRoot, 'validation_figures', 'generate_validation_figures.m'));

% The validation script begins with clear/close/clc, so restore launcher state.
thisRoot = fileparts(mfilename('fullpath'));
outDir = fullfile(thisRoot, 'Figs');
addpath(genpath(thisRoot));

fprintf('  Done.\n\n');

% % 3) Co-design box set (BOX_26..30)
% fprintf('[3/3] Running co-design box analyses (BOX_26..30)...\n');
% run_all_codesign_analyses('OutDir', outDir, 'CopyNodeTableToMS2', false);
% fprintf('  Done.\n\n');
% 
% fprintf('All figure pipelines completed.\n');
% fprintf('Check output folder: %s\n', outDir);
end
