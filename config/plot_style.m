function plot_style()
%PLOT_STYLE Configure default plotting aesthetics for all figures.

% Typography and weights (centralized control)
set(groot, 'defaultAxesFontName', 'CMU Serif');
set(groot, 'defaultAxesFontSize', 12);
set(groot, 'defaultAxesFontWeight', 'bold');
set(groot, 'defaultAxesLabelFontSizeMultiplier', 1.1);
set(groot, 'defaultAxesTitleFontSizeMultiplier', 1.15);
set(groot, 'defaultAxesTitleFontWeight', 'bold');
set(groot, 'defaultLegendFontSize', 11);

% Lines, markers, and colors
set(groot, 'defaultLineLineWidth', 2);
set(groot, 'defaultLineMarkerSize', 7);
set(groot, 'defaultAxesColorOrder', lines(8));

% Axes appearance
set(groot, 'defaultAxesLineWidth', 1.1);
set(groot, 'defaultAxesTickDir', 'out');
set(groot, 'defaultAxesXMinorTick', 'on');
set(groot, 'defaultAxesYMinorTick', 'on');
set(groot, 'defaultAxesGridAlpha', 0.25);
set(groot, 'defaultAxesMinorGridAlpha', 0.15);
set(groot, 'defaultAxesBox', 'on');
set(groot, 'defaultAxesColor', [1 1 1]);
set(groot, 'defaultAxesGridLineStyle', '-');

% Figures and legends
set(groot, 'defaultFigureColor', 'w');
set(groot, 'defaultFigurePosition', [200 200 700 500]);
set(groot, 'defaultLegendLocation', 'best');
set(groot, 'defaultLegendBox', 'off');

% Colorbars
set(groot, 'defaultColorbarFontSize', 11);
end
