
function box13_extracted_params(ax1, ax2, meta, fitResult, ci, style)
    axes(ax1);
    seriesList0 =  {'Conventional Ru', 'Sputtered Ru', 'Textured Ru'};
    % Plot p and R per condition (with optional CIs)
    seriesList = fitResult.seriesList;
    pv = zeros(numel(seriesList),1);
    Rv = zeros(numel(seriesList),1);
    tdv = zeros(numel(seriesList),1);
    for k = 1:numel(seriesList)
        s = seriesList(k);
        ps = fitResult.perSeries.(s);
        pv(k) = ps.p;
        Rv(k) = ps.R;
        tdv(k) = ps.tdead_nm;
    end
    
    yyaxis left;
    plot(1:numel(seriesList), pv, '-o', 'Color', style.colors.blue, 'MarkerFaceColor', style.colors.blue, 'LineWidth', style.lineWidth);
    ylabel('p (-)','FontWeight','bold');
    xlim([0.5,3.5]);
    
    yyaxis right;
    plot(1:numel(seriesList), Rv, '-s', 'Color', style.colors.red, 'MarkerFaceColor', style.colors.red, 'LineWidth', style.lineWidth);
    ylabel('R (-)','FontWeight','bold');
    set(gca,'XTick',1:numel(seriesList),'XTickLabel',cellstr(seriesList0));
    xtickangle(20);
    title('(c) Extracted Scattering Parameters','FontWeight','bold');
    grid on;
    xlim([0.5,3.5]);
    
    axes(ax2);
    % Show tdead and anchored D
    hold on;
    D = zeros(numel(seriesList),1);
    for k = 1:numel(seriesList)
        s = seriesList(k);
        D(k) = fitResult.perSeries.(s).D_nm;
    end
    bar(1:numel(seriesList), tdv, 'FaceColor', style.colors.orange);
    plot(1:numel(seriesList), D/100, '-^', 'Color', style.colors.green, 'MarkerFaceColor', style.colors.green, 'LineWidth', style.lineWidth);
    set(gca,'XTick',1:numel(seriesList),'XTickLabel',cellstr(seriesList0));
    xtickangle(20);
    ylabel('t_{dead} (nm) and D/100','FontWeight','bold');
    title('(d) Area-Loss {\itvs.} Grain Size','FontWeight','bold');
    grid on; alpha(0.4);
end