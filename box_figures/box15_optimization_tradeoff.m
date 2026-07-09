function box15_optimization_tradeoff(ax1, ax2, meta, fitResult, style)
    axes(ax1);
    hold on;
    % Compare baseline (conventional) vs textured at same t
    th = linspace(6, 20, 200);
    
    sA = "Conventional_ALD_Ru";
    sB = "Textured_ALD_Ru";
    prmA = base_params(fitResult, fitResult.perSeries.(sA));
    prmB = base_params(fitResult, fitResult.perSeries.(sB));
    
    rhoA = rho_total(th, prmA, fitResult.baseFlags, meta);
    rhoB = rho_total(th, prmB, fitResult.baseFlags, meta);
    
    plot(th, rhoA, '-', 'Color', style.series.conventional_ALD_Ru, 'LineWidth', style.lineWidth);
    plot(th, rhoB, '-', 'Color', style.series.textured_ALD_Ru, 'LineWidth', style.lineWidth);
    
    xlabel('Thickness, t (nm)','FontWeight','bold');
    ylabel('\rho (\mu\Omega\cdotcm)','FontWeight','bold');
    title('(c) Predicted Best-Case vs Baseline','FontWeight','bold');
    legend({'Conventional Ru','Textured Ru'}, 'Location','best');
    grid on;
    
    axes(ax2);
    % Tradeoff: resistivity at 10 nm vs required p (illustrative sweep)
    cla; hold on;
    pSweep = linspace(0.1, 0.9, 60);
    ps = fitResult.perSeries.("Textured_ALD_Ru");
    prm = base_params(fitResult, ps);
    prm.p = pSweep;
    prm.tdead_nm = ps.tdead_nm;
    
    rho10 = rho_total(10*ones(size(pSweep)), prm, fitResult.baseFlags, meta);
    plot(pSweep, rho10, '-', 'Color', style.colors.purple, 'LineWidth', style.lineWidth);
    xlabel('Specularity, p','FontWeight','bold');
    ylabel('\rho(t=10nm) (\mu\Omega\cdotcm)','FontWeight','bold');
    title('(d) Tradeoff: \rho {\itvs.} Required Specularity','FontWeight','bold');
    grid on;
end