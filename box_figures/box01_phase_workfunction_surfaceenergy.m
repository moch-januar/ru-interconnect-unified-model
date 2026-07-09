function box01_phase_workfunction_surfaceenergy(ax1, ax2, dft, style)
  % Left: work function; Right: surface energy
    axes(ax1);
    bar([dft.fcc.phi_eV, dft.hcp.phi_eV], 'FaceColor', style.colors.blue);
    set(gca,'XTickLabel',{'fcc','hcp'});
    ylabel('Work Function (eV)','FontWeight','bold');
    title('(b) Work Function','FontWeight','bold');
    grid on; alpha(0.4);
    
    axes(ax2);
    bar([dft.fcc.gamma_Jm2, dft.hcp.gamma_Jm2], 'FaceColor', style.colors.orange);
    set(gca,'XTickLabel',{'fcc','hcp'});
    xlabel('Lattice Structure','FontWeight','bold');
    ylabel('Surface Energy (J m^{-2})','FontWeight','bold');
    title('(c) Surface Energy','FontWeight','bold');
    grid on; alpha(0.4);

    nexttile();
    % facet area fractions
    ph = [dft.hcp.facet_area(:)', 0];
    pf = [dft.fcc.facet_area(:)', 0];
    M = [ph(1:3); pf(1:3)];
    
    bar(categorical({'hcp','fcc'}), M, 'stacked');
    ylabel('Facet area fraction','FontWeight','bold');
    title('(d) Dominant facet','FontWeight','bold','FontSize',10);
    grid on; alpha(0.4);
    
    legNames = {char(dft.hcp.facets(1)), char(dft.hcp.facets(2)), char(dft.hcp.facets(3))};
    legend(legNames, 'Location','best');
end
