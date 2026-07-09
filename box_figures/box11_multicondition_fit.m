function box11_multicondition_fit(ax1, ax2, data, meta, fitResult, style)
    axes(ax1);
    hold on;
    seriesList = fitResult.seriesList;
    for k = 1:numel(seriesList)
        s = seriesList(k);
        mask = data.series == s;
        t = data.t_nm(mask);
        y = data.y(mask);
        ps = fitResult.perSeries.(s);
    
        prm = base_params(fitResult, ps);
        rho = rho_total(t, prm, fitResult.baseFlags, meta);
        yhat = ps.scale_s .* rho;
    
        c = style.series.(s);
        plot(t, y, 'o', 'Color', c, 'MarkerFaceColor', c, 'MarkerSize', style.markerSize);
        plot(t, yhat, '-', 'Color', c, 'LineWidth', style.lineWidth,'HandleVisibility','off');
    end
    xlabel('Thickness (nm)','FontWeight','bold');
    ylabel('Resistivity (norm)','FontWeight','bold');
    title('(a) Multi-Condition Fits','FontWeight','bold');

    seriesList0 =  {'Conventional Ru', 'Sputtered Ru', 'Textured Ru'};
    seriesList00 =  {'Conventional', 'Sputtered', 'Textured'};
    legend(cellstr(seriesList00), 'Location','northeast');
    grid on;
    
    axes(ax2);
    cla; hold on;
    errs = [];
    labels = {};
    for k = 1:numel(seriesList)
        s = seriesList(k);
        mask = data.series == s;
        t = data.t_nm(mask);
        y = data.y(mask);
        ps = fitResult.perSeries.(s);
        prm = base_params(fitResult, ps);
        rho = rho_total(t, prm, fitResult.baseFlags, meta);
        yhat = ps.scale_s .* rho;
        e = yhat - y;
        errs = [errs; e(:)]; %#ok<AGROW>
        labels = [labels; repmat({char(seriesList0(k))}, numel(e), 1)]; %#ok<AGROW>
    end
    
    g = categorical(labels);

bc = boxchart(g, errs, ...
    'BoxFaceAlpha', 0.25, ...        % keep box light so points stand out
    'MarkerStyle', 'o', ...
    'MarkerSize', 4, ...
    'JitterOutliers', 'on');         % helps spread points

ylabel('Residual (a.u.)','FontWeight','bold');
title('(b) Residual Distributions','FontWeight','bold');
grid on;

end