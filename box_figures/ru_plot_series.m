function [series, params, metal] = ru_plot_series(fitResult, style)
% RU_PLOT_SERIES Helper to get Ru model params + series meta for plots.

params = params_default();

% Select Ru metal (fallback to first entry)
idx = find(strcmp({params.metals.name}, 'Ru'), 1);
if isempty(idx)
    idx = 1;
end
metal = params.metals(idx);

% Optional: switchable EM prefactor calibration via style_defaults().
emMode = 'as_configured';
emScale = [];
if nargin >= 2 && isstruct(style) && isfield(style, 'reliability') && isfield(style.reliability, 'EM')
    if isfield(style.reliability.EM, 'mode') && ~isempty(style.reliability.EM.mode)
        emMode = string(style.reliability.EM.mode);
    end
    if isfield(style.reliability.EM, 'scaleA0')
        emScale = style.reliability.EM.scaleA0;
    end
end

if ~isempty(emScale) && isnumeric(emScale) && isfinite(emScale) && emScale > 0
    if isfield(metal, 'A0_EM') && ~isempty(metal.A0_EM)
        metal.A0_EM = metal.A0_EM * emScale;
    end
else
    switch lower(char(emMode))
        case 'tuned10yr'
            if isfield(metal, 'A0_EM_tuned10yr') && ~isempty(metal.A0_EM_tuned10yr)
                metal.A0_EM = metal.A0_EM_tuned10yr;
            end
        case 'nominal'
            if isfield(metal, 'A0_EM_nominal') && ~isempty(metal.A0_EM_nominal)
                metal.A0_EM = metal.A0_EM_nominal;
            end
        otherwise
            % as_configured (no change)
    end
end

% Override with fitted globals where available
if isfield(fitResult, 'global')
    if isfield(fitResult.global, 'rho300_uohmcm')
        metal.rho0 = fitResult.global.rho300_uohmcm * 1e-8;
    end
    if isfield(fitResult.global, 'lambda_nm')
        metal.lambda = fitResult.global.lambda_nm * 1e-9;
    end
    if isfield(fitResult.global, 'tq_nm')
        metal.wq = fitResult.global.tq_nm * 1e-9;
    end
    if isfield(fitResult.global, 'Aq')
        metal.Aq = fitResult.global.Aq;
    end
end
if isfield(fitResult, 'alpha_TCR')
    metal.alpha_TCR = fitResult.alpha_TCR;
end

seriesOrder = {'Conventional_ALD_Ru', 'Sputtered_Ru', 'Textured_ALD_Ru'};
seriesLabels = {'Conventional Ru', 'Sputtered Ru', 'Textured Ru'};

series = struct('name', {}, 'label', {}, 'ps', {}, 'color', {});
for i = 1:numel(seriesOrder)
    name = seriesOrder{i};
    if isfield(fitResult.perSeries, name)
        s = struct;
        s.name = name;
        s.label = seriesLabels{i};
        s.ps = fitResult.perSeries.(name);
        if isfield(style, 'series') && isfield(style.series, name)
            s.color = style.series.(name);
        else
            s.color = style.colors.deepBlue;
        end
        series(end+1) = s; %#ok<AGROW>
    end
end
end
