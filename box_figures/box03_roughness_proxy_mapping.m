function box03_roughness_proxy_mapping(ax1, ax2, dft, style)
    axes(ax1);
    vals = [dft.hcp.RPI, dft.fcc.RPI]
    bar(vals, 'FaceColor', style.colors.purple);
    set(gca,'XTickLabel',{'hcp','fcc'});
    xlabel('Lattice structure','FontWeight','bold');
    ylabel('RPI = std(\gamma_i)/mean(\gamma_i)','FontWeight','bold');
    title('(a) DFT \rightarrow roughness propensity (proxy)','FontWeight','bold');
    grid on;
    
    axes(ax2);
  % Map RPI to effective t_dead examples
    rpi = linspace(0, 0.25, 100);
    tdead = 0.2 + 4.0*rpi; % nm, illustrative mapping
    plot(rpi, tdead, 'Color', style.colors.blue, 'LineWidth', style.lineWidth);
    xlabel('RPI (dimensionless)','FontWeight','bold');
    ylabel('t_{dead} proxy (nm)','FontWeight','bold');
    title('(b) Proxy mapping (illustrative)','FontWeight','bold');
    grid on;
end