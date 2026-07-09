function figs = make_box_figures(params, metal, data, fit, diag, opt)
%MAKE_BOX_FIGURES Create strict 1x2 (two-panel) figures for LaTeX boxes.

figs = struct();

figs.BOX_01 = make_box_01(params, metal, data, fit, diag);
figs.BOX_02 = make_box_02(params, metal, data, fit, diag);
figs.BOX_03 = make_box_03(fit, diag);
figs.BOX_04 = make_box_04(data, fit);

% Verify strict axes count = 2
names = fieldnames(figs);
for i = 1:numel(names)
    f = figs.(names{i});
    ax = findall(f, 'Type', 'axes');
    if numel(ax) ~= 2
        error('%s must contain exactly 2 subplots/axes. Found %d.', names{i}, numel(ax));
    end
end
end

function f = new_box_figure()
% IEEE-ish compact aspect for 2-panel row
f = figure('Color','w', 'Units','inches', 'Position',[1 1 6.8 2.6]);
f.Renderer = 'painters';
tiledlayout(f, 1, 2, 'TileSpacing','compact', 'Padding','compact');
% Resolve CMU Serif with fallback
fonts = listfonts;
if any(strcmpi(fonts, 'CMU Serif'))
    fontName = 'CMU Serif';
elseif any(contains(fonts, 'CMU', 'IgnoreCase', true))
    fontName = fonts{find(contains(fonts, 'CMU', 'IgnoreCase', true), 1)};
else
    fontName = 'Times New Roman';
end
set(f, 'DefaultAxesFontName', fontName, 'DefaultTextFontName', fontName);
end

function apply_ax_style(ax)
fonts = listfonts;
if any(strcmpi(fonts, 'CMU Serif'))
    fontName = 'CMU Serif';
elseif any(contains(fonts, 'CMU', 'IgnoreCase', true))
    fontName = fonts{find(contains(fonts, 'CMU', 'IgnoreCase', true), 1)};
else
    fontName = 'Times New Roman';
end
set(ax, 'FontName', fontName, 'FontSize', 11, 'FontWeight', 'bold', ...
    'LineWidth', 1.4, 'Box', 'on');
ax.TickDir = 'out';
ax.TickLength = [0.015 0.015];
grid(ax, 'on');
% Ensure labels are bold and large
ax.XLabel.FontSize = 12;
ax.XLabel.FontWeight = 'bold';
ax.YLabel.FontSize = 12;
ax.YLabel.FontWeight = 'bold';
ax.Title.FontSize = 12;
ax.Title.FontWeight = 'bold';
end

function f = make_box_01(params, metal, data, fit, diag)
% (left) rho(T) overlay; (right) residuals vs T.

f = new_box_figure();

T = diag.temp.T;
rho_const_u = diag.temp.rho_const * 1e8;
rho_inv_u = diag.temp.rho_inv * 1e8;
rho_proxy_u = diag.temp.rho_data_proxy * 1e8;

ax1 = nexttile;
plot(T, rho_proxy_u, 'k.', 'MarkerSize', 10); hold on;
plot(T, rho_const_u, '-', 'Color', [0.10 0.45 0.85], 'LineWidth', 2.2);
plot(T, rho_inv_u, '--', 'Color', [0.85 0.33 0.10], 'LineWidth', 2.2);
apply_ax_style(ax1);
xlabel(ax1, 'Temperature T (K)');
ylabel(ax1, 'Resistivity \rho (\mu\Omega\cdotcm)');
legend(ax1, {'Proxy (TCR-only, anchored @10 nm)', 'FS+MS (\lambda const)', 'FS+MS (\lambda \propto 1/\rho_0(T))'}, ...
    'Location','northwest', 'FontSize', 7);
title(ax1, 'Temperature Dependence (Sensitivity)');

ax2 = nexttile;
res_const = rho_const_u - rho_proxy_u;
res_inv = rho_inv_u - rho_proxy_u;
plot(T, res_const, '-', 'Color', [0.10 0.45 0.85], 'LineWidth', 2.2); hold on;
plot(T, res_inv, '--', 'Color', [0.85 0.33 0.10], 'LineWidth', 2.2);
yline(ax2, 0, 'k:', 'LineWidth', 1.2);
apply_ax_style(ax2);
xlabel(ax2, 'Temperature T (K)');
ylabel(ax2, 'Residual \Delta\rho (\mu\Omega\cdotcm)');
title(ax2, 'Residual vs T (Model - Proxy)');

end

function f = make_box_02(params, metal, data, fit, diag)
% (left) rho vs thickness; (right) percent error vs thickness.

f = new_box_figure();

th_nm = data.thickness_nm;
y = data.rho_uohmcm;

geom300 = struct('w_m', data.w_m, 't_m', data.t_m, 'T_K', data.T_ref_K * ones(size(data.t_m)));

theta_fs = fit.fs.theta; theta_fs.alpha_TCR = metal.alpha_TCR;
theta_ms = fit.ms.theta; theta_ms.alpha_TCR = metal.alpha_TCR;
theta_c = fit.combined.theta; theta_c.alpha_TCR = metal.alpha_TCR;

rho_fs = model_FS(params, metal, geom300, theta_fs, struct('lambda_T_mode','const')) * 1e8;
rho_ms = model_MS(params, metal, geom300, theta_ms, struct()) * 1e8;
rho_c  = (model_FS(params, metal, geom300, theta_c, struct('lambda_T_mode','const')) .* mayadas_shatzkes(theta_c.lambda0, theta_c.D, theta_c.R)) * 1e8;

% Monte Carlo band (if available)
band_lo = [];
band_hi = [];
if isfield(diag, 'mc') && isfield(diag.mc, 'enabled') && diag.mc.enabled
    band_lo = diag.mc.rho_p05 * 1e8;
    band_hi = diag.mc.rho_p95 * 1e8;
end

ax1 = nexttile;
plot(th_nm, y, 'k.', 'MarkerSize', 9); hold on;
if ~isempty(band_lo)
    fill([th_nm; flipud(th_nm)], [band_lo; flipud(band_hi)], [0.10 0.45 0.85], ...
        'FaceAlpha', 0.15, 'EdgeColor', 'none');
end
plot(th_nm, rho_fs, '-', 'Color', [0.10 0.45 0.85], 'LineWidth', 2.2);
plot(th_nm, rho_ms, '-', 'Color', [0.55 0.55 0.55], 'LineWidth', 1.6);
plot(th_nm, rho_c, '--', 'Color', [0.85 0.33 0.10], 'LineWidth', 2.2);
apply_ax_style(ax1);
xlabel(ax1, 'Thickness t (nm)');
ylabel(ax1, 'Resistivity \rho (\mu\Omega\cdotcm)');
if ~isempty(band_lo)
    legend(ax1, {'Data', 'FS band (5-95% MC)', 'FS fit', 'MS-only (should fail)', 'FS\timesMS fit'}, 'Location','northeast', 'FontSize', 7);
else
    legend(ax1, {'Data', 'FS fit', 'MS-only (should fail)', 'FS\timesMS fit'}, 'Location','northeast', 'FontSize', 7);
end
title(ax1, 'Ru Resistivity Scaling');

ax2 = nexttile;
err_fs = 100*(rho_fs - y)./y;
err_c = 100*(rho_c - y)./y;
plot(th_nm, err_fs, '-', 'Color', [0.10 0.45 0.85], 'LineWidth', 2.2); hold on;
plot(th_nm, err_c, '--', 'Color', [0.85 0.33 0.10], 'LineWidth', 2.2);
yline(ax2, 0, 'k:', 'LineWidth', 1.2);
apply_ax_style(ax2);
xlabel(ax2, 'Thickness t (nm)');
ylabel(ax2, 'Percent error (%)');
title(ax2, 'Fit Error vs Thickness');

end

function f = make_box_03(fit, diag)
% (left) extracted params w/ CI (global here); (right) corr heatmap.

f = new_box_figure();

ax1 = nexttile;
apply_ax_style(ax1);

% Parameters to report
th = fit.combined.theta;
name = {'\lambda (nm)','p','R','D (nm)','t_{dead} (nm)'};
val = [th.lambda0, th.p, th.R, th.D, th.t_dead] .* [1e9, 1, 1, 1e9, 1e9];

ci = nan(2, numel(val));
if isfield(diag, 'bootstrap') && isfield(diag.bootstrap, 'enabled') && diag.bootstrap.enabled
    order = diag.bootstrap.nameOrder;
    ci95 = diag.bootstrap.ci95;
    % map order
    for i = 1:numel(name)
        switch i
            case 1, idx = find(strcmp(order, 'lambda0')); scale = 1e9;
            case 2, idx = find(strcmp(order, 'p')); scale = 1;
            case 3, idx = find(strcmp(order, 'R')); scale = 1;
            case 4, idx = find(strcmp(order, 'D')); scale = 1e9;
            case 5, idx = find(strcmp(order, 't_dead')); scale = 1e9;
        end
        if ~isempty(idx)
            ci(:,i) = ci95(:,idx) * scale;
        end
    end
end

x = 1:numel(val);
bar(ax1, x, val, 0.7, 'FaceColor', [0.25 0.55 0.85]); hold on;
if all(isfinite(ci(:)))
    er = errorbar(ax1, x, val, val - ci(1,:), ci(2,:) - val, 'k.', 'LineWidth', 1.4, 'CapSize', 10);
end
set(ax1, 'XTick', x, 'XTickLabel', name);
xtickangle(ax1, 20);
ylabel(ax1, 'Extracted value (with 95% CI)');
title(ax1, 'Fitted Parameters (Global)');

ax2 = nexttile;
apply_ax_style(ax2);
C = diag.identifiability.Corr;
if any(isnan(C(:)))
    imagesc(ax2, zeros(size(C)));
    title(ax2, 'Correlation heatmap (ill-conditioned)');
else
    imagesc(ax2, C);
    title(ax2, 'Parameter Correlation (Identifiability)');
end
colormap(ax2, redblue());
cb = colorbar(ax2);
cb.Label.String = 'corr';
clim(ax2, [-1 1]);
set(ax2, 'XTick', 1:numel(diag.identifiability.names), 'XTickLabel', diag.identifiability.names, 'XTickLabelRotation', 45);
set(ax2, 'YTick', 1:numel(diag.identifiability.names), 'YTickLabel', diag.identifiability.names);
axis(ax2, 'tight');

end

function f = make_box_04(data, fit)
% (left) model comparison overlay; (right) AIC/BIC/GoF.

f = new_box_figure();

ax1 = nexttile;
apply_ax_style(ax1);

th_nm = data.thickness_nm;
plot(th_nm, data.rho_uohmcm, 'k.', 'MarkerSize', 9); hold on;
plot(th_nm, fit.fs.y_hat*1e8, '-', 'Color', [0.10 0.45 0.85], 'LineWidth', 2.2);
plot(th_nm, fit.ms.y_hat*1e8, '-', 'Color', [0.55 0.55 0.55], 'LineWidth', 1.6);
plot(th_nm, fit.combined.y_hat*1e8, '--', 'Color', [0.85 0.33 0.10], 'LineWidth', 2.2);
xlabel(ax1, 'Thickness t (nm)');
ylabel(ax1, 'Resistivity \rho (\mu\Omega\cdotcm)');
legend(ax1, {'Data','FS','MS-only','FS\timesMS'}, 'Location','northeast', 'FontSize', 7);
title(ax1, 'Model Comparison');

ax2 = nexttile;
apply_ax_style(ax2);

models = {'FS','MS','FS\timesMS'};
AIC = [fit.fs.aic, fit.ms.aic, fit.combined.aic];
BIC = [fit.fs.bic, fit.ms.bic, fit.combined.bic];
RMSE = [fit.fs.rmse, fit.ms.rmse, fit.combined.rmse] * 1e8;

x = 1:3;
bar(ax2, x-0.22, AIC - min(AIC), 0.20, 'FaceColor', [0.3 0.6 0.9]); hold on;
bar(ax2, x,     BIC - min(BIC), 0.20, 'FaceColor', [0.9 0.5 0.2]);
plot(ax2, x+0.22, RMSE, 'k-o', 'LineWidth', 1.8, 'MarkerFaceColor','k', 'MarkerSize', 4);
set(ax2, 'XTick', x, 'XTickLabel', models);
xlabel(ax2, 'Model');
ylabel(ax2, 'AIC/BIC (\Delta, lower is better)  and  RMSE (\mu\Omega\cdotcm)');
title(ax2, 'AIC/BIC and RMSE Summary');
legend(ax2, {'\DeltaAIC','\DeltaBIC','RMSE'}, 'Location','northwest', 'FontSize', 7);

end

function cmap = redblue()
% Simple diverging colormap
n = 256;
r = [(0:n-1)'/(n-1), zeros(n,1), (n-1:-1:0)'/(n-1)];
% shift to blue-white-red
cmap = [linspace(0,1,n/2)' linspace(0,1,n/2)' ones(n/2,1);
        ones(n/2,1) linspace(1,0,n/2)' linspace(1,0,n/2)'];
end
