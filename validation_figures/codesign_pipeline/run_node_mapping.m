function tbl = run_node_mapping(out_dir, varargin)
%RUN_NODE_MAPPING Technology-node mapping table (Step 3).
%   tbl = run_node_mapping(out_dir)
%
%   Maps IRDS-like technology nodes (N3, N2, A14, A10) to predicted
%   R_line, MTF, tau_RC, f_3dB, DeltaT for all metal conditions.
%   Outputs a formatted LaTeX table fragment and a .mat file.
%
%   Produces: node_table.tex, node_table.mat

p = inputParser;
p.addParameter('export_dpi', 600, @isscalar);
p.parse(varargin{:});

if ~exist(out_dir, 'dir'), mkdir(out_dir); end

metals = codesign_params();
allIdx = 1:5;

% Technology nodes: name, Mx min pitch (nm), w (nm), t (nm), L (um)
% Based on IRDS 2022 "More Moore" BEOL roadmap
% Pitch and width from IRDS Table MM15, aspect ratios 2.4-2.8 per roadmap trend
nodes = struct();
nodes(1).name = 'N3';   nodes(1).pitch = 21;  nodes(1).w = 10;  nodes(1).t = 24;  nodes(1).L = 1.0;
nodes(2).name = 'N2';   nodes(2).pitch = 16;  nodes(2).w = 8;   nodes(2).t = 20;  nodes(2).L = 0.8;
nodes(3).name = 'A14';  nodes(3).pitch = 12;  nodes(3).w = 6;   nodes(3).t = 16;  nodes(3).L = 0.6;
nodes(4).name = 'A10';  nodes(4).pitch = 10;  nodes(4).w = 5;   nodes(4).t = 14;  nodes(4).L = 0.5;
nNodes = numel(nodes);
nMet   = numel(allIdx);

J0 = 1e11;  % 10 MA/cm^2

% Build table
col_names = {'Node', 'Metal', 'w_nm', 't_nm', 'L_um', 'Rline', 'MTF_hr', 'tau_ps', 'f3dB_GHz', 'DT_K'};
nRows = nNodes * nMet;
data = cell(nRows, numel(col_names));

row = 0;
for in = 1:nNodes
    nd = nodes(in);
    w_m = nd.w * 1e-9;
    t_m = nd.t * 1e-9;
    L_m = nd.L * 1e-6;

    for mi = 1:nMet
        row = row + 1;
        met = metals(allIdx(mi));

        % Check feasibility
        dead_w = met.t_dead + met.barrier;
        dead_t = met.t_dead + met.barrier;
        if w_m < 2*dead_w + 1e-9 || t_m < 2*dead_t + 1e-9
            data(row, :) = {nd.name, met.name, nd.w, nd.t, nd.L, NaN, NaN, NaN, NaN, NaN};
            continue;
        end

        [Rl, mtf, tau, f3, ~] = compute_metrics(met, w_m, t_m, L_m, J0);
        [~, ~, dT] = solve_electrothermal(met, w_m, t_m, L_m, J0);

        data(row, :) = {nd.name, met.name, nd.w, nd.t, nd.L, ...
            Rl, mtf, tau*1e12, f3/1e9, dT};
    end
end

tbl = cell2table(data, 'VariableNames', col_names);

% Save .mat
save(fullfile(out_dir, 'node_table.mat'), 'tbl', 'nodes', 'metals');

% Convert MTF from hours to years for consistency with Fig_BOX_23
hrs_per_yr = 365.25 * 24;

% Write LaTeX fragment
fid = fopen(fullfile(out_dir, 'node_table.tex'), 'w');
fprintf(fid, '%% Auto-generated technology-node mapping table\n');
fprintf(fid, '\\begin{table*}[!t]\n');
fprintf(fid, '\\centering\n');
fprintf(fid, '\\caption{Predicted interconnect metrics at IRDS technology nodes ($J=\\SI{10}{MA/cm^2}$).}\n');
fprintf(fid, '\\label{tab:node_map}\n');
fprintf(fid, '\\footnotesize\n');
fprintf(fid, '\\begin{tabular}{@{}llcccccccc@{}}\n');
fprintf(fid, '\\toprule\n');
fprintf(fid, 'Node & Metal & $w$ & $t$ & $L$ & $R_{\\mathrm{line}}$ & MTF & $\\tau_{RC}$ & $f_{3\\mathrm{dB}}$ & $\\Delta T$ \\\\\n');
fprintf(fid, ' & & (nm) & (nm) & ($\\mu$m) & ($\\Omega/\\mu$m) & (yr) & (ps) & (GHz) & (K) \\\\\n');
fprintf(fid, '\\midrule\n');

prevNode = '';
for row = 1:nRows
    nd  = data{row, 1};
    met = data{row, 2};
    if ~strcmp(nd, prevNode) && row > 1
        fprintf(fid, '\\midrule\n');
    end
    prevNode = nd;

    Rl   = data{row, 6};
    mtf  = data{row, 7};
    tau  = data{row, 8};
    f3   = data{row, 9};
    dT   = data{row, 10};

    if isnan(Rl)
        fprintf(fid, '%s & %s & %d & %d & %.1f & \\multicolumn{5}{c}{infeasible} \\\\\n', ...
            nd, met, data{row,3}, data{row,4}, data{row,5});
    else
        mtf_yr = mtf / hrs_per_yr;  % convert hours to years
        fprintf(fid, '%s & %s & %d & %d & %.1f & %.0f & %.1e & %.2f & %.1f & %.1f \\\\\n', ...
            nd, met, data{row,3}, data{row,4}, data{row,5}, Rl, mtf_yr, tau, f3, dT);
    end
end

fprintf(fid, '\\bottomrule\n');
fprintf(fid, '\\end{tabular}\n');
fprintf(fid, '\\end{table*}\n');
fclose(fid);

fprintf('  Saved: %s\n', fullfile(out_dir, 'node_table.tex'));
fprintf('  Saved: %s\n', fullfile(out_dir, 'node_table.mat'));
end
