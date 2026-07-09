function fig_runaway = run_thermal_runaway_map(out_dir, varargin)
%RUN_THERMAL_RUNAWAY_MAP Thermal runaway boundary in (J,w) space (Step 4).
%   fig = run_thermal_runaway_map(out_dir)
%
%   Identifies the (J,w) conditions where the iterative thermal solver
%   fails to converge (thermal runaway), and overlays this boundary on
%   the EM reliability cliff.  Produces:
%     Fig_BOX_30.png — (a) Convergence map, (b) DeltaT contour + runaway
%
%   This figure demonstrates a prediction unique to the self-consistent
%   solver that is invisible to isothermal analysis.

p = inputParser;
p.addParameter('export_dpi', 600, @isscalar);
p.addParameter('Nj', 80, @isscalar);
p.addParameter('Nw', 80, @isscalar);
p.parse(varargin{:});
dpi = p.Results.export_dpi;
Nj  = p.Results.Nj;
Nw  = p.Results.Nw;

if ~exist(out_dir, 'dir'), mkdir(out_dir); end

metals = codesign_params();
ruIdx  = [1 2 3];  % three Ru conditions

J_vec = linspace(1e10, 3e11, Nj);   % 1-30 MA/cm^2
w_vec = linspace(4e-9, 30e-9, Nw);
t_fix = 10e-9;
L_fix = 1e-6;

% Compute convergence and DeltaT maps for each Ru condition
map_data = struct();
for ri = 1:numel(ruIdx)
    met = metals(ruIdx(ri));
    conv_map = false(Nj, Nw);
    DT_map   = NaN(Nj, Nw);
    MTF_map  = NaN(Nj, Nw);

    dead_w = met.t_dead + met.barrier;
    dead_t = met.t_dead + met.barrier;

    for ij = 1:Nj
        for iw = 1:Nw
            ww = w_vec(iw);
            if ww < 2*dead_w + 2e-9 || t_fix < 2*dead_t + 2e-9
                continue;
            end
            [Tl, ~, dT, cflag] = solve_electrothermal(met, ww, t_fix, L_fix, J_vec(ij));
            conv_map(ij, iw) = cflag;
            DT_map(ij, iw) = dT;
            if cflag
                [~, mtf] = compute_metrics(met, ww, t_fix, L_fix, J_vec(ij));
                MTF_map(ij, iw) = mtf;
            end
        end
    end

    map_data(ri).name     = met.label;
    map_data(ri).color    = met.color;
    map_data(ri).conv_map = conv_map;
    map_data(ri).DT_map   = DT_map;
    map_data(ri).MTF_map  = MTF_map;
end

J_MA = J_vec / 1e10;   % MA/cm^2
w_nm = w_vec * 1e9;

% =====================================================================
%  Figure: Convergence + DeltaT for all three Ru conditions
% =====================================================================
fig1 = figure('Units', 'centimeters', 'Position', [2 2 18 14], ...
    'Color', 'w', 'PaperPositionMode', 'auto');
tiledlayout(2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

% (a) Convergence/runaway boundary overlay
nexttile;
hold on;
lineStyles = {'-', '--', '-.'};
for ri = 1:3
    md = map_data(ri);
    contour(w_nm, J_MA, double(md.conv_map), [0.5 0.5], ...
        'Color', md.color, 'LineWidth', 2.2, 'LineStyle', lineStyles{ri});
end
xlabel('Width (nm)', 'FontWeight', 'bold');
ylabel('J (MA/cm^2)', 'FontWeight', 'bold');
title('(a) Thermal Convergence Boundary', 'FontSize', 10);
legend({map_data.name}, 'Location', 'northwest', 'FontSize', 7);
grid on; box on;
annotation_text = 'Converged (below) / Runaway (above)';
text(0.5, 0.05, annotation_text, 'Units', 'normalized', 'FontSize', 7, ...
    'HorizontalAlignment', 'center', 'FontAngle', 'italic');

% (b) DeltaT contour for textured Ru
nexttile;
DT_text = map_data(3).DT_map;
DT_text(~map_data(3).conv_map) = NaN;
contourf(w_nm, J_MA, DT_text, 15, 'LineWidth', 0.5);
colormap(gca, hot);
cb = colorbar; cb.Label.String = '\DeltaT (K)';
hold on;
% Overlay runaway boundary
contour(w_nm, J_MA, double(map_data(3).conv_map), [0.5 0.5], ...
    'Color', 'c', 'LineWidth', 2.5, 'LineStyle', '-');
xlabel('Width (nm)', 'FontWeight', 'bold');
ylabel('J (MA/cm^2)', 'FontWeight', 'bold');
title('(b) \DeltaT Map: Textured Ru', 'FontSize', 10);
grid on; box on;

% (c) EM MTF contour for textured Ru with 10-yr line
% Convert MTF from hours to years for consistency with Fig_BOX_23
hrs_per_yr = 365.25 * 24;
nexttile;
MTF_text = map_data(3).MTF_map;
MTF_text(MTF_text <= 0 | ~isfinite(MTF_text)) = NaN;
MTF_text_yr = MTF_text / hrs_per_yr;
logMTF = log10(MTF_text_yr);
contourf(w_nm, J_MA, logMTF, 12, 'LineWidth', 0.5);
colormap(gca, parula);
cb = colorbar; cb.Label.String = 'log_{10}(MTF) [years]';
hold on;
MTF_10yr = 10;  % years
contour(w_nm, J_MA, logMTF, log10(MTF_10yr)*[1 1], 'r-', 'LineWidth', 2.5);
contour(w_nm, J_MA, double(map_data(3).conv_map), [0.5 0.5], ...
    'Color', 'c', 'LineWidth', 2, 'LineStyle', '--');
xlabel('Width (nm)', 'FontWeight', 'bold');
ylabel('J (MA/cm^2)', 'FontWeight', 'bold');
title('(c) MTF + Runaway: Textured Ru', 'FontSize', 10);
grid on; box on;

% (d) Comparison: Conventional vs Textured DeltaT at J=10 MA/cm^2
nexttile;
hold on;
J_target_idx = find(J_MA >= 10, 1, 'first');
for ri = [1 3]  % Conv and Textured
    md = map_data(ri);
    DT_slice = md.DT_map(J_target_idx, :);
    valid = ~isnan(DT_slice);
    plot(w_nm(valid), DT_slice(valid), '-', 'Color', md.color, 'LineWidth', 2.2, ...
        'DisplayName', md.name);
end
yline(100, 'k--', 'LineWidth', 1.2, 'HandleVisibility', 'off');
xlabel('Width (nm)', 'FontWeight', 'bold');
ylabel('\DeltaT (K)', 'FontWeight', 'bold');
title('(d) \DeltaT vs. Width at J=10 MA/cm^2', 'FontSize', 10);
legend('Location', 'northeast', 'FontSize', 7);
grid on; box on;

polish_figure(fig1);
exportgraphics(fig1, fullfile(out_dir, 'Fig_BOX_30.png'), 'Resolution', dpi);
fprintf('  Saved: %s\n', fullfile(out_dir, 'Fig_BOX_30.png'));

fig_runaway = struct('fig1', fig1);
end
