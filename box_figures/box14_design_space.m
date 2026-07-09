

function box14_design_space(ax1, ax2, meta, fitResult, style)
    % Sweep thickness and tdead for textured ALD using fitted p,R
    s  = "Textured_ALD_Ru";
    ps = fitResult.perSeries.(s);
    
    axes(ax1);
    T  = linspace(5, 25, 120);
    TD = linspace(0, 1.2, 80);
    [TT, TDD] = meshgrid(T, TD);
    
    prm = base_params(fitResult, ps);
    prm.p = ps.p;
    prm.R = ps.R;
    prm.tdead_nm = TDD;
    
    rho = rho_total(TT, prm, fitResult.baseFlags, meta);
    imagesc(T, TD, rho);
    axis xy;
    colorbar;
    xlabel('Thickness (nm)','FontWeight','bold');
    ylabel('Thickness dead-zone (nm)','FontWeight','bold');
    title('(a) Design Space: \rho(t, t_{dead})','FontWeight','bold');
    colormap("jet")
    
    axes(ax2);
    hold on;
    % Highlight target region (example threshold)
    contour(T, TD, rho, [9 10 11], 'LineWidth', 1.4);
    xlabel('Thickness (nm)','FontWeight','bold');
    ylabel('Thickness dead-zone (nm)','FontWeight','bold');
    title('(b) Contours (\mu\Omega\cdotcm) & Feasible Zone','FontWeight','bold');
    grid on;
end
    
