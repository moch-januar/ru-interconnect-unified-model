function box26_bandwidth_reliability(ax1, ax2, fitResult, style)
% BOX26 Bandwidth vs reliability constraints.

[series, params, metal] = ru_plot_series(fitResult, style);

warnState1 = warning('off', 'reliability_model:ShortLife');
warnState2 = warning('off', 'electrothermal_model:ThermalRunaway');
cleanup    = onCleanup(@() warning(warnState1.state, 'reliability_model:ShortLife'));
cleanup2   = onCleanup(@() warning(warnState2.state, 'electrothermal_model:ThermalRunaway'));

if isempty(series)
    return;
end

h_ILD = 20e-9;
s_spacing = 12e-9;
line_length = 50e-6;
J = 10; % MA/cm^2
L_thermal = line_length;

axes(ax1);
hold on;
ys = [];
for i = 1:numel(series)
    ps = series(i).ps;
    D = ps.D_nm * 1e-9;
    w_nm = linspace(6, 22, 30);
    bw_ghz = zeros(size(w_nm));
    MTF_years = zeros(size(w_nm));
    for j = 1:numel(w_nm)
        w = w_nm(j) * 1e-9;
        t = 1.4 * w;
        A = w * t;
        I = J * 1e10 * A;
        rho_eff = rho_unified(params, metal, w, t, ps.p, ps.R, D, 'auto');
        [~, ~, ~, metrics] = rc_delay_model(params, metal, w, t, h_ILD, rho_eff, ...
            struct('s', s_spacing, 'length', line_length));
        [T_avg, rho_eff_T] = electrothermal_model(params, metal, w, t, ps.p, ps.R, D, I, 300, 'L_wire', L_thermal);
        [MTF, ~] = reliability_model(params, metal, w, t, rho_eff_T, T_avg, I);
        bw_ghz(j) = metrics.f_3dB / 1e9;
        MTF_years(j) = max(MTF / (365.25 * 24 * 3600), 1e-6); % MTF is in seconds
    end
    ys = [ys; MTF_years(:)]; %#ok<AGROW>
    scatter(bw_ghz, MTF_years, 45, series(i).color, 'filled', 'MarkerEdgeColor', style.colors.charcoal, 'LineWidth', 0.3, 'MarkerFaceAlpha', 0.75);
end
set(ax1, 'YScale', 'linear');
xlabel('3 dB bandwidth (GHz)', 'FontWeight','bold');
ylabel('MTF (years)', 'FontWeight','bold');
title('(c) Bandwidth {\itvs.} Reliability', 'FontWeight','bold');
% grid on;
legend({series.label}, 'Location', 'best');

% Use log scaling for reliability span
set(ax1, 'YScale', 'log', 'YTick', [1e-2,1e-1,1e0,1e1,1e2]);
ylim([5e-4,500]);

% ys = ys(isfinite(ys) & (ys > 0));
% if ~isempty(ys)
%     ymin = max(min(ys) / 1.8, 0.01);
%     ymax = min(max(ys) * 1.8, 10);
%     ylim([ymin ymax]);
% else
%     ylim([0.01 10]);
% end

axes(ax2);
hold on;
[ps, ~, ~, found] = ru_find_series(series, 'Textured_ALD_Ru', style);
if ~found
    return;
end
D = ps.D_nm * 1e-9;
w_nm = linspace(6, 22, 50);
L_um = linspace(5, 150, 60);
[WW, LL] = meshgrid(w_nm, L_um);
BW = zeros(size(WW));
for k = 1:numel(WW)
    w = WW(k) * 1e-9;
    t = 1.4 * w;
    rho_eff = rho_unified(params, metal, w, t, ps.p, ps.R, D, 'auto');
    [~, ~, ~, metrics] = rc_delay_model(params, metal, w, t, h_ILD, rho_eff, ...
        struct('s', s_spacing, 'length', LL(k) * 1e-6));
    BW(k) = metrics.f_3dB / 1e9;
end
imagesc(w_nm, L_um, BW);
axis xy tight;
colormap(ax2, parula);
cb = colorbar('FontSize',10);
cb.Label.String = '3 dB bandwidth (GHz)';
cb.Label.FontSize = 11;

% Compute width threshold for 10-year MTF
MTF_years = zeros(size(w_nm));
for j = 1:numel(w_nm)
    w = w_nm(j) * 1e-9;
    t = 1.4 * w;
    A = w * t;
    I = J * 1e10 * A;
    [T_avg, rho_eff_T] = electrothermal_model(params, metal, w, t, ps.p, ps.R, D, I, 300, 'L_wire', L_thermal);
    [MTF, ~] = reliability_model(params, metal, w, t, rho_eff_T, T_avg, I);
    MTF_years(j) = MTF / (365.25 * 24 * 3600); % MTF is in seconds
end
idx = find(MTF_years >= 10, 1, 'first');
if ~isempty(idx)
    xline(w_nm(idx), 'w--', 'LineWidth', 2.0);
end

xlabel('Width (nm)', 'FontWeight','bold');
ylabel('Length (\mum)', 'FontWeight','bold');
title('(d) Bandwidth Map (Textured Ru)', 'FontWeight','bold');
end
