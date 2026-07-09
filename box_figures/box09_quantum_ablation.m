

function box09_quantum_ablation(ax1, ax2, data, meta, fitResult, style)
    % Left: quantum factor vs thickness
    axes(ax1);
    t = linspace(5, 25, 200);
    Fq = quantum_correction(t, fitResult.global.tq_nm, fitResult.global.Aq, 3);
    plot(t, Fq, 'Color', style.colors.green, 'LineWidth', style.lineWidth);
    xlabel('Thickness (nm)','FontWeight','bold');
    ylabel('F_q (dimensionless)','FontWeight','bold');
    title('(c) Quantum proxy term','FontWeight','bold');
    grid on;
    
    % Right: with vs without Q
    axes(ax2);
    cla;
    hold on;
    s = "Textured_ALD_Ru";
    mask = data.series == s;
    td = data.t_nm(mask);
    y = data.y(mask);
    ps = fitResult.perSeries.(s);
    base = base_params(fitResult, ps);
    
    flags0 = struct('useFS',true,'useMS',true,'useArea',true,'useQ',false);
    flags1 = struct('useFS',true,'useMS',true,'useArea',true,'useQ',true);
    
    rho0 = rho_total(td, base, flags0, meta);
    rho1 = rho_total(td, base, flags1, meta);
    
    y0 = ps.scale_s .* rho0;
    y1 = ps.scale_s .* rho1;
    
    plot(td, y, 'o', 'Color', style.series.textured_ALD_Ru, 'MarkerFaceColor', style.colors.warmOrange, 'MarkerSize', style.markerSize);
    plot(td, y0, '--', 'Color', style.colors.crimson, 'LineWidth', style.lineWidth);
    plot(td, y1, '-', 'Color', style.colors.green, 'LineWidth', style.lineWidth);
    
    xlabel('Thickness (nm)','FontWeight','bold');
    ylabel('Resistivity (norm)','FontWeight','bold');
    title('(d) With vs without quantum term','FontWeight','bold');
    legend({'Experiment','No-Q','With-Q'}, 'Location','northeast');
    grid on;
    ylim([35.1,59.9])
end