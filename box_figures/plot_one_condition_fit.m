% --------- helper for plotting a representative fit + residuals ---------
function plot_one_condition_fit(ax1, ax2, data, meta, fitResultCurve, style, seriesName, flags, titlePrefix, fitResultOverlay)
    if nargin < 10
        fitResultOverlay = [];
    end
    
    axes(ax1);
    cla; hold on;
    mask = data.series == seriesName;
    t = data.t_nm(mask);
    y = data.y(mask);
    ps = fitResultCurve.perSeries.(seriesName);
    
    prm = base_params(fitResultCurve, ps);
    rho = rho_total(t, prm, flags, meta);
    yhat = ps.scale_s .* rho;
    
    if ~isempty(fitResultOverlay)
        ps0 = fitResultOverlay.perSeries.(seriesName);
        prm0 = base_params(fitResultOverlay, ps0);
        rho0 = rho_total(t, prm0, flags, meta);
        yhat0 = ps0.scale_s .* rho0;
        plot(t, yhat0, '--', 'Color', style.colors.gray, 'LineWidth', 1.2);
    end
    
    c = style.series.(seriesName);
    plot(t, y, 'o', 'Color', c, 'MarkerFaceColor', style.colors.warmOrange, 'MarkerSize', style.markerSize);
    plot(t, yhat, '-', 'Color', c, 'LineWidth', style.lineWidth);
    
    xlabel('t (nm)','FontWeight','bold');
    ylabel('Resistivity (norm)','FontWeight','bold');
    title([titlePrefix],'FontWeight','bold');
    if ~isempty(fitResultOverlay)
        legend({'Base-fit (same flags)','Experiment','Refit'}, 'Location','best');
    else
        legend({'Experiment','Model'}, 'Location','northeast');
    end
    grid on;
    ylim([35.1,59.9])
    
    axes(ax2);
    cla; hold on;
    res = yhat - y;
    stem(t, res, 'Color', style.colors.gray, 'LineWidth', 1.2, 'Marker','none');
    plot(t, zeros(size(t)), '--', 'Color', style.colors.gray, 'LineWidth', 1.0);
    xlabel('t (nm)','FontWeight','bold');
    ylabel('Residual (a.u.)','FontWeight','bold');
    title('Residuals','FontWeight','bold');
    grid on;
    ylim([-14.9,-0.001])
end