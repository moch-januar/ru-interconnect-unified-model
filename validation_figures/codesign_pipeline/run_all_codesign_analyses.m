function run_all_codesign_analyses(varargin)
%RUN_ALL_CODESIGN_ANALYSES Master script for Manuscript 2 additional results.
%
%   This script executes all four strengthening analyses for the
%   co-design manuscript:
%     Step 1: Sensitivity / uncertainty propagation (Fig_BOX_26, 27)
%     Step 2: Cross-metal benchmarking Ru/Cu/Mo   (Fig_BOX_28, 29)
%     Step 3: Technology-node mapping table        (node_table.tex)
%     Step 4: Thermal runaway map                  (Fig_BOX_30)
%
%   Usage:
%     >> cd('path/to/codesign_pipeline')
%     >> run_all_codesign_analyses
%     >> run_all_codesign_analyses('OutDir', 'C:/path/to/output')
%
%   Default outputs go to ../../../figures/ (relative to this script).

close all; clc;
t_start = tic;

p = inputParser;
p.addParameter('OutDir', '', @(s) ischar(s) || isstring(s));
p.addParameter('CopyNodeTableToMS2', true, @(x) islogical(x) || isnumeric(x));
p.parse(varargin{:});
opt = p.Results;
opt.CopyNodeTableToMS2 = logical(opt.CopyNodeTableToMS2);

% --- Uniform figure styling: CMU Serif, bold, 11-pt base ---
set_figure_style();

% Resolve output directories
scriptDir = fileparts(mfilename('fullpath'));
out_dir = fullfile(scriptDir, '..', 'RSC-JMCC', 'Figs');
if ~exist(out_dir, 'dir'), mkdir(out_dir); end
ms_dir = fullfile(scriptDir, '..', '..', 'Manuscript2_CoDesign');  % for LaTeX table

fprintf('=== Co-Design Manuscript Analyses ===\n');
fprintf('Output directory: %s\n\n', out_dir);

% Ensure this pipeline's functions are on the path
addpath(scriptDir);

% ------------------------------------------------------------------
fprintf('[Step 1/4] Sensitivity / Uncertainty Propagation ...\n');
run_sensitivity_analysis(out_dir, 'N_MC', 800, 'rng_seed', 42);
fprintf('  Done.\n\n');

% ------------------------------------------------------------------
fprintf('[Step 2/4] Cross-Metal Benchmarking (Ru/Cu/Mo) ...\n');
run_cross_metal_benchmark(out_dir, 'Nw', 80, 'Nt', 60);
fprintf('  Done.\n\n');

% ------------------------------------------------------------------
fprintf('[Step 3/4] Technology-Node Mapping Table ...\n');
tbl = run_node_mapping(out_dir);
Also copy LaTeX table to manuscript directory
if opt.CopyNodeTableToMS2 && exist(ms_dir, 'dir')
	copyfile(fullfile(out_dir, 'node_table.tex'), fullfile(ms_dir, 'node_table.tex'));
elseif opt.CopyNodeTableToMS2
	fprintf('  Note: Manuscript2_CoDesign folder not found, skipping node_table copy.\n');
end
Print summary to console
fprintf('\n  --- Node Mapping Summary ---\n');
disp(tbl);
fprintf('\n');

% ------------------------------------------------------------------
fprintf('[Step 4/4] Thermal Runaway Map ...\n');
run_thermal_runaway_map(out_dir, 'Nj', 60, 'Nw', 60);
fprintf('  Done.\n\n');

% ------------------------------------------------------------------
elapsed = toc(t_start);
fprintf('=== All analyses complete (%.1f s) ===\n', elapsed);
fprintf('Generated figures:\n');
fprintf('  Fig_BOX_26.png — Sensitivity: MTF distributions + sensitivity indices\n');
fprintf('  Fig_BOX_27.png — Sensitivity: DT-Rline scatter + RC delay uncertainty\n');
fprintf('  Fig_BOX_28.png — Benchmark:   Pareto fronts (all metals)\n');
fprintf('  Fig_BOX_29.png — Benchmark:   Reliability windows + BW vs MTF\n');
fprintf('  Fig_BOX_30.png — Runaway:     Thermal convergence/runaway map\n');
fprintf('  node_table.tex — LaTeX table fragment for technology nodes\n');
end
