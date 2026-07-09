function fontName = set_figure_style()
%SET_FIGURE_STYLE Set global figure defaults: CMU Serif, bold, large labels.
%   fontName = set_figure_style()
%   Configures groot defaults for all subsequent figures.
%   Falls back to Times New Roman if CMU Serif is unavailable.
%
%   Style targets (match generate_vlsi2026_figures_v2.m conventions):
%     Tick labels : 11 pt, bold, CMU Serif
%     Axis labels : 12 pt, bold
%     Title       : 12 pt, bold
%     Legend      :  9 pt
%     Line width  :  2.2 pt

% --- Resolve font availability ---
fonts = listfonts;
if any(strcmpi(fonts, 'CMU Serif'))
    fontName = 'CMU Serif';
elseif any(contains(fonts, 'CMU', 'IgnoreCase', true))
    idx = find(contains(fonts, 'CMU', 'IgnoreCase', true), 1);
    fontName = fonts{idx};
else
    warning('set_figure_style:FontMissing', ...
        'CMU Serif not found. Install from https://cm-unicode.sourceforge.io/. Using Times New Roman.');
    fontName = 'Times New Roman';
end

% --- Global groot defaults ---
set(groot, 'defaultAxesFontName',                fontName);
set(groot, 'defaultAxesFontSize',                11);
set(groot, 'defaultAxesFontWeight',              'bold');
set(groot, 'defaultAxesLineWidth',               1.4);
set(groot, 'defaultAxesTitleFontWeight',         'bold');
set(groot, 'defaultAxesTitleFontSizeMultiplier', 1.1);   % 11*1.1 ≈ 12
set(groot, 'defaultAxesLabelFontSizeMultiplier', 1.1);   % 11*1.1 ≈ 12
set(groot, 'defaultTextFontName',                fontName);
set(groot, 'defaultTextFontSize',                11);
set(groot, 'defaultTextFontWeight',              'bold');
set(groot, 'defaultLineLineWidth',               2.2);
set(groot, 'defaultFigureColor',                 'w');

fprintf('Figure style set: %s, bold, 11-pt base.\n', fontName);
end
