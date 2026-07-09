function box06_model_fit_comparison(ax1, ax2, data, meta, fitResult, style, ablFits)
%% BOX06 Model fit comparison (FS-only vs MS-only vs FS+MS) on the same axis.
    
    seriesName = "Textured_ALD_Ru";
    seriesCol  = get_series_col(data);
    tcol       = get_num_col(data, ["t_nm","Thickness_nm","thickness_nm","t","th_nm"]);
    ycol       = get_num_col(data, ["y","NormResistivity","normresistivity","rho_norm","rho"]);
    
    mask = seriesCol == seriesName;
    t = tcol(mask);
    y = ycol(mask);
    
    fitFS = pick_fit(ablFits, 'FS-only', fitResult);
    fitMS = pick_fit(ablFits, 'MS-only', fitResult);
    fitFSMs = pick_fit(ablFits, 'FS-MS', fitResult);
    
    flagsFS = struct('useFS',true,'useMS',false,'useArea',true,'useQ',false);
    flagsMS = struct('useFS',false,'useMS',true,'useArea',true,'useQ',false);
    flagsFSMs = struct('useFS',true,'useMS',true,'useArea',true,'useQ',false);
    
    [yhatFS, okFS] = predict_curve(t, seriesName, fitFS, flagsFS, meta);
    [yhatMS, okMS] = predict_curve(t, seriesName, fitMS, flagsMS, meta);
    [yhatFSMs, okFSMs] = predict_curve(t, seriesName, fitFSMs, flagsFSMs, meta);
    
    axes(ax1);
    cla;
    hold on;
    
    % Experiment
    plot(t, y, 'o', 'Color', style.colors.charcoal, 'MarkerFaceColor', style.colors.warmOrange, ...
        'MarkerSize', style.markerSize, 'LineWidth', 1.2);
    
    % Model curves
    if okFS
        plot(t, yhatFS, '-', 'Color', style.colors.deepBlue, 'LineWidth', 2.6);
    end
    if okMS
        plot(t, yhatMS, ':', 'Color', style.colors.warmOrange, 'LineWidth', 2.6);
    end
    if okFSMs
        plot(t, yhatFSMs, '--', 'Color', style.colors.crimson, 'LineWidth', 2.8);
    end
    
    xlabel('Thickness (nm)', 'FontWeight','bold');
    ylabel('Resistivity (norm)', 'FontWeight','bold');
    title('(a) Model Comparison (Textured Ru)', 'FontWeight','bold');
    grid on;
    
    labels = {'Experiment'};
    if okFS, labels{end+1} = 'FS-only'; end
    if okMS, labels{end+1} = 'MS-only'; end
    if okFSMs, labels{end+1} = 'FS+MS'; end
    legend(labels, 'Location', 'northeast');
    
    finiteY = y(:);
    if okFS, finiteY = [finiteY; yhatFS(:)]; end
    if okMS, finiteY = [finiteY; yhatMS(:)]; end
    if okFSMs, finiteY = [finiteY; yhatFSMs(:)]; end
    finiteY = finiteY(isfinite(finiteY));
    if ~isempty(finiteY)
        lo = min(finiteY); hi = max(finiteY);
        pad = 0.08 * max(1, hi - lo);
        ylim([lo - pad, hi + pad]);
    end
    
    
    axes(ax2);
    cla;
    hold on;
    
    plot(t, zeros(size(t)), '--', 'Color', [0.35 0.35 0.35], 'LineWidth', 1.2, 'HandleVisibility','off');
    
    maxAbs = 0;
    if okFS
	    rFS = yhatFS - y;
	    plot(t, rFS, '-o', 'Color', style.colors.deepBlue, 'MarkerFaceColor', [1 1 1], ...
		    'MarkerSize', 6, 'LineWidth', 2.0);
	    maxAbs = max(maxAbs, max(abs(rFS(isfinite(rFS)))));
    end
    if okMS
	    rMS = yhatMS - y;
	    plot(t, rMS, ':s', 'Color', style.colors.warmOrange, 'MarkerFaceColor', [1 1 1], ...
		    'MarkerSize', 6, 'LineWidth', 2.0);
	    maxAbs = max(maxAbs, max(abs(rMS(isfinite(rMS)))));
    end
    if okFSMs
	    rFSMs = yhatFSMs - y;
	    plot(t, rFSMs, '--^', 'Color', style.colors.crimson, 'MarkerFaceColor', [1 1 1], ...
		    'MarkerSize', 6, 'LineWidth', 2.2);
	    maxAbs = max(maxAbs, max(abs(rFSMs(isfinite(rFSMs)))));
    end
    
    xlabel('Thickness (nm)', 'FontWeight','bold');
    ylabel('Residual (a.u.)', 'FontWeight','bold');
    title('(b) Fitting residual (Textured Ru)', 'FontWeight','bold');
    grid on;
    
    labels = {};
    if okFS, labels{end+1} = 'FS-only (Surf. Scatt.)'; end
    if okMS, labels{end+1} = 'MS-only (GB Scatt.)'; end
    if okFSMs, labels{end+1} = 'FS+MS (Surf.+GB Scatt.)'; end
    if ~isempty(labels)
	    legend(labels, 'Location', 'northwest');
    end
    
    if isfinite(maxAbs) && maxAbs > 0
	    pad = 0.15 * maxAbs;
	    ylim([-maxAbs - pad, maxAbs + pad]);
    end

end

function s = get_series_col(data)
if istable(data)
    if ismember('series', data.Properties.VariableNames), s = string(data.series); return; end
    if ismember('Series', data.Properties.VariableNames), s = string(data.Series); return; end
end
if isstruct(data)
    if isfield(data, 'series'), s = string(data.series); return; end
    if isfield(data, 'Series'), s = string(data.Series); return; end
end
error('box06_model_fit_comparison:MissingSeries', 'Could not find series column in data.');
end

function v = get_num_col(data, names)
if istable(data)
    for i = 1:numel(names)
        n = char(names(i));
        if ismember(n, data.Properties.VariableNames)
            v = double(data.(n));
            return;
        end
    end
elseif isstruct(data)
    for i = 1:numel(names)
        n = char(names(i));
        if isfield(data, n)
            v = double(data.(n));
            return;
        end
    end
end
error('box06_model_fit_comparison:MissingColumn', 'Could not find numeric column in data: %s', strjoin(cellstr(names), ', '));
end

function [yhat, ok] = predict_curve(t, seriesName, fitRes, flags, meta)
    ok = false;
    yhat = nan(size(t));
    if isempty(fitRes) || ~isstruct(fitRes) || ~isfield(fitRes, 'perSeries')
        return;
    end
    if ~isfield(fitRes.perSeries, seriesName)
        return;
    end
    ps = fitRes.perSeries.(seriesName);
    prm = base_params(fitRes, ps);
    rho = rho_total(t, prm, flags, meta);
    yhat = ps.scale_s .* rho;
    ok = any(isfinite(yhat));
end

