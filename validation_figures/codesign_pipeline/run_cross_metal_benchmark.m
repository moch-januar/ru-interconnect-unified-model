function fig_bench = run_cross_metal_benchmark(out_dir, varargin)
%RUN_CROSS_METAL_BENCHMARK Ru vs Cu vs Mo comparison & reliability windows (Step 2).
%   fig = run_cross_metal_benchmark(out_dir)
%
%   Compares all metal conditions across a range of wire widths at fixed
%   aspect ratio (AR=2), showing R_line vs MTF trade-off curves for each
%   metal in the design space.  Also maps reliability windows.  Produces:
%     Fig_BOX_28.png — (a) R_line-MTF cross-metal curves, (b) bar comparison at fixed w
%     Fig_BOX_29.png — (a) Reliability windows in (J,w), (b) BW vs MTF
%
%   This provides the Cu/Mo context that IEEE TED reviewers will expect.
%
%   Literature context:
%     Cu barrier penalty at sub-7 nm: Ciofi et al., IEEE TED 63 (2016)
%     Mo as barrierless alternative: Liang et al., IITC (2018)
%     Ru texturing benefits: Leem et al., IEDM (2025)

p = inputParser;
p.addParameter('export_dpi', 600, @isscalar);
p.addParameter('Nw', 100, @isscalar);
p.addParameter('Nt', 80, @isscalar);
p.parse(varargin{:});
dpi = p.Results.export_dpi;
Nw  = p.Results.Nw;

if ~exist(out_dir, 'dir'), mkdir(out_dir); end

metals = codesign_params();
% Indices: 1=Ru-Conv, 2=Ru-Sput, 3=Ru-Text, 4=Cu, 5=Mo
allIdx = 1:5;
nMet   = numel(allIdx);

L0 = 1e-6;   % 1 um
J0 = 1e11;   % 10 MA/cm^2
AR = 2;      % aspect ratio t/w

% ---- Cross-metal R_line vs MTF curves at fixed AR ----
w_sweep = linspace(5e-9, 50e-9, Nw);
curve_data = struct();
for mi = 1:nMet
    met = metals(allIdx(mi));
    Rl = NaN(1, Nw);
    Ml = NaN(1, Nw);
    for iw = 1:Nw
        ww = w_sweep(iw);
        tt = AR * ww;
        dead_w = met.t_dead + met.barrier;
        dead_t = met.t_dead + met.barrier;
        if ww < 2*dead_w + 2e-9 || tt < 2*dead_t + 2e-9
            continue;
        end
        [Rlv, mtfv] = compute_metrics(met, ww, tt, L0, J0);
        if mtfv > 0 && isfinite(mtfv) && Rlv > 0 && isfinite(Rlv)
            Rl(iw) = Rlv;
            Ml(iw) = mtfv;
        end
    end
    curve_data(mi).name  = met.label;
    curve_data(mi).color = met.color;
    curve_data(mi).Rl    = Rl;
    curve_data(mi).Ml    = Ml;
    curve_data(mi).w_nm  = w_sweep * 1e9;
    valid = sum(~isnan(Rl));
    fprintf('  Curve computed for %s: %d valid points\n', met.label, valid);
end

% ---- Reliability windows: J vs w for all metals ----
J_vec = linspace(1e10, 2e11, 60);   % 1-20 MA/cm^2
w_rel = linspace(5e-9, 30e-9, 60);
t_fix = 10e-9;                       % fixed thickness
MTF_10yr = 10 * 365.25 * 24;         % hours

rel_window = struct();
for mi = 1:nMet
    met = metals(allIdx(mi));
    pass = false(numel(J_vec), numel(w_rel));
    for ij = 1:numel(J_vec)
        for iw = 1:numel(w_rel)
            ww = w_rel(iw);
            dead_w = met.t_dead + met.barrier;
            dead_t = met.t_dead + met.barrier;
            if ww < 2*dead_w + 2e-9 || t_fix < 2*dead_t + 2e-9
                continue;
            end
            [~, mtf, ~, ~] = compute_metrics(met, ww, t_fix, L0, J_vec(ij));
            [Tl] = solve_electrothermal(met, ww, t_fix, L0, J_vec(ij));
            if mtf >= MTF_10yr && Tl <= 400
                pass(ij, iw) = true;
            end
        end
    end
    rel_window(mi).pass  = pass;
    rel_window(mi).name  = met.label;
    rel_window(mi).color = met.color;
end

% ---- BW vs MTF at fixed w, varying L ----
L_vec = linspace(0.2e-6, 5e-6, 50);
w_bw = 10e-9;
bw_data = struct();
for mi = 1:nMet
    met = metals(allIdx(mi));
    dead_w = met.t_dead + met.barrier;
    dead_t = met.t_dead + met.barrier;
    if w_bw < 2*dead_w + 2e-9 || t_fix < 2*dead_t + 2e-9
        bw_data(mi).MTF = NaN(size(L_vec));
        bw_data(mi).BW  = NaN(size(L_vec));
        continue;
    end
    mtf_v = zeros(size(L_vec));
    bw_v  = zeros(size(L_vec));
    for il = 1:numel(L_vec)
        [~, mtf_v(il), ~, bw_v(il)] = compute_metrics(met, w_bw, t_fix, L_vec(il), J0);
    end
    bw_data(mi).MTF  = mtf_v;
    bw_data(mi).BW   = bw_v;
    bw_data(mi).name = met.label;
    bw_data(mi).color = met.color;
end

% =====================================================================
%  Figure 1: R_line-MTF cross-metal curves + fixed-width comparison
% =====================================================================
fig1 = figure('Units', 'centimeters', 'Position', [2 2 18 8], ...
    'Color', 'w', 'PaperPositionMode', 'auto');
tiledlayout(1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

% (a) R_line vs MTF curves, parameterized by width at fixed AR
% Convert MTF from hours to years for consistency with Fig_BOX_23
hrs_per_yr = 365.25 * 24;
nexttile;
hold on;
for mi = 1:nMet
    cd = curve_data(mi);
    valid = ~isnan(cd.Rl) & ~isnan(cd.Ml);
    if sum(valid) > 1
        plot(cd.Rl(valid), cd.Ml(valid) / hrs_per_yr, '-', 'Color', cd.color, 'LineWidth', 2.2, ...
            'DisplayName', cd.name);
        % Mark key widths: 10, 20, 40 nm
        for wmark = [10 20 40]
            [~, idx] = min(abs(cd.w_nm - wmark));
            if valid(idx)
                plot(cd.Rl(idx), cd.Ml(idx) / hrs_per_yr, 'o', 'MarkerSize', 6, ...
                    'MarkerFaceColor', cd.color, 'MarkerEdgeColor', 'k', ...
                    'LineWidth', 0.8, 'HandleVisibility', 'off');
            end
        end
    end
end
set(gca, 'YScale', 'log');
xlabel('R_{line} (\Omega/\mum)', 'FontWeight', 'bold');
ylabel('MTF (years)', 'FontWeight', 'bold');
title('(a) R_{line} vs. MTF (AR=2, J=10 MA/cm^2)', 'FontSize', 10);
MTF_10yr_yr = 10;  % years
yline(MTF_10yr_yr, 'k--', 'LineWidth', 1.5, 'HandleVisibility', 'off');
legend('Location', 'southwest', 'FontSize', 6);
grid on; box on;

% (b) Rline and MTF at w=10nm, t=10nm as grouped bar
nexttile;
met_labels = cell(nMet, 1);
Rbar = zeros(nMet, 1);
Mbar = zeros(nMet, 1);
cbar = zeros(nMet, 3);
for mi = 1:nMet
    met = metals(allIdx(mi));
    dead_w = met.t_dead + met.barrier;
    dead_t = met.t_dead + met.barrier;
    if 10e-9 < 2*dead_w + 2e-9 || 10e-9 < 2*dead_t + 2e-9
        Rbar(mi) = NaN;
        Mbar(mi) = NaN;
    else
        [Rbar(mi), Mbar(mi)] = compute_metrics(met, 10e-9, 10e-9, L0, J0);
    end
    met_labels{mi} = met.name;
    cbar(mi, :) = met.color;
end

yyaxis left;
bh = bar(1:nMet, Rbar, 0.5);
bh.FaceColor = 'flat';
for mi = 1:nMet
    bh.CData(mi,:) = cbar(mi,:);
end
ylabel('R_{line} (\Omega/\mum)', 'FontWeight', 'bold');

yyaxis right;
Mbar_yr = Mbar / hrs_per_yr;
plot(1:nMet, log10(max(Mbar_yr, 1e-10)), 's-', 'Color', [0.3 0.3 0.3], ...
    'MarkerFaceColor', [0.5 0.5 0.5], 'LineWidth', 1.8, 'MarkerSize', 8);
ylabel('log_{10}(MTF) [years]', 'FontWeight', 'bold');

set(gca, 'XTick', 1:nMet, 'XTickLabel', met_labels, 'XTickLabelRotation', 25);
title('(b) Comparison at w=t=10 nm', 'FontSize', 10);
grid on; box on;

polish_figure(fig1);
exportgraphics(fig1, fullfile(out_dir, 'Fig_BOX_28.png'), 'Resolution', dpi);
fprintf('  Saved: %s\n', fullfile(out_dir, 'Fig_BOX_28.png'));

% =====================================================================
%  Figure 2: Reliability windows + BW vs MTF
% =====================================================================
fig2 = figure('Units', 'centimeters', 'Position', [2 2 18 8], ...
    'Color', 'w', 'PaperPositionMode', 'auto');
tiledlayout(1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

% (a) Reliability windows (contour overlay)
nexttile;
hold on;
J_MA = J_vec / 1e10;   % in MA/cm^2
w_nm = w_rel * 1e9;
lineStyles = {'-', '--', '-.', ':', '-'};
for mi = 1:nMet
    rw = rel_window(mi);
    contour(w_nm, J_MA, double(rw.pass), [0.5 0.5], ...
        'Color', rw.color, 'LineWidth', 2, 'LineStyle', lineStyles{mi});
end
xlabel('Width (nm)', 'FontWeight', 'bold');
ylabel('J (MA/cm^2)', 'FontWeight', 'bold');
title('(a) 10-yr Reliability Windows', 'FontSize', 10);
legend({rel_window.name}, 'Location', 'northeast', 'FontSize', 6);
grid on; box on;

% (b) BW vs MTF
nexttile;
hold on;
for mi = 1:nMet
    bd = bw_data(mi);
    if ~all(isnan(bd.MTF))
        plot(bd.MTF / hrs_per_yr, bd.BW/1e9, '-', 'Color', bd.color, 'LineWidth', 2, ...
            'DisplayName', bd.name);
    end
end
set(gca, 'XScale', 'log');
xlabel('MTF (years)', 'FontWeight', 'bold');
ylabel('f_{3dB} (GHz)', 'FontWeight', 'bold');
title('(b) Bandwidth vs. EM Lifetime', 'FontSize', 10);
xline(MTF_10yr_yr, 'k--', 'LineWidth', 1.5, 'HandleVisibility', 'off');
legend('Location', 'northeast', 'FontSize', 6);
grid on; box on;

polish_figure(fig2);
exportgraphics(fig2, fullfile(out_dir, 'Fig_BOX_29.png'), 'Resolution', dpi);
fprintf('  Saved: %s\n', fullfile(out_dir, 'Fig_BOX_29.png'));

fig_bench = struct('fig1', fig1, 'fig2', fig2);
end
