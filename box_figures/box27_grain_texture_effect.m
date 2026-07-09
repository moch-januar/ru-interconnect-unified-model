function box27_grain_texture_effect(ax1, ax2, fitResult, style)
% BOX27 Grain texture effect on resistivity and GB reduction trend.
D_nm = linspace(20, 200, 80);
[series, params, metal] = ru_plot_series(fitResult, style);
if isempty(series)
    return;
end

% Use conventional and textured series to map texture -> R0
[ps_textured, ~, ~, foundTex] = ru_find_series(series, 'Textured_ALD_Ru', style);
if ~foundTex
    return;
end
[ps_random, ~, ~, foundConv] = ru_find_series(series, 'Conventional_ALD_Ru', style);
if ~foundConv
    ps_random = ps_textured;
end

R_random = ps_random.R;
R_textured = ps_textured.R;

w_nm = linspace(6, 60, 80);
texture_levels = [0.0, 0.3, 0.7, 1.0];
colors = [style.colors.crimson; style.colors.warmOrange; style.colors.deepBlue; style.colors.teal];

axes(ax1);
    hold on;
    for i = 1:numel(texture_levels)
        tex = texture_levels(i);
        R0 = R_random - (R_random - R_textured) * tex;
        rho = zeros(size(w_nm));
        for j = 1:numel(w_nm)
            w = w_nm(j) * 1e-9;
            t = 1.4 * w;
            rho(j) = rho_unified(params, metal, w, t, ps_textured.p, R0, ps_textured.D_nm * 1e-9, 'auto');
        end
        rho_ratio = rho / metal.rho0;
        plot(w_nm, rho_ratio, 'Color', colors(i,:), 'LineWidth', 2.6);
    end
    xlabel('Width (nm)', 'FontWeight','bold');
    ylabel('\rho / \rho_0', 'FontWeight','bold');
    title('(b) Grain texture effect', 'FontWeight','bold');
    legend({'Texture = 0.0', 'Texture = 0.3', 'Texture = 0.7', 'Texture = 1.0'}, 'Location', 'northeast');
    grid on;

axes(ax2);
    hold on;
    w0 = 10e-9;
    t0 = 1.4 * w0;
    for i = 1:numel(series)
        ps = series(i).ps;
        rho_u = zeros(size(D_nm));
        for j = 1:numel(D_nm)
            rho = rho_unified(params, metal, w0, t0, ps.p, ps.R, D_nm(j) * 1e-9, 'auto');
            rho_u(j) = rho * 1e8; % uOhm*cm
        end
        plot(D_nm, rho_u, 'Color', series(i).color, 'LineWidth', 2.6);
    end
    xlabel('Grain size D (nm)', 'FontWeight','bold');
    ylabel('Resistivity (\mu\Omega\cdotcm)', 'FontWeight','bold');
    title('(a) Resistivity {\itvs.} grain size', 'FontWeight','bold');
    grid on;
end
