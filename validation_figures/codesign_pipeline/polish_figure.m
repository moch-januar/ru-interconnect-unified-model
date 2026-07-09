function polish_figure(fig)
%POLISH_FIGURE Enforce uniform bold CMU Serif styling on every axes in fig.
%   polish_figure(fig)
%   Iterates over all axes, colorbars, and legends and ensures bold tick
%   labels, 12-pt axis labels/titles, and consistent formatting.
%   Call this right before exportgraphics for final polishing.

if nargin < 1, fig = gcf; end

% --- Axes ---
axs = findall(fig, 'Type', 'axes');
for i = 1:numel(axs)
    ax = axs(i);
    set(ax, 'FontWeight', 'bold', 'LineWidth', 1.4, 'Box', 'on');
    ax.TickDir = 'in';
    ax.TickLength = [0.015 0.015];

    % Axis labels: 12 pt bold
    if ~isempty(ax.XLabel.String)
        set(ax.XLabel, 'FontSize', 12, 'FontWeight', 'bold');
    end
    if ~isempty(ax.YLabel.String)
        set(ax.YLabel, 'FontSize', 12, 'FontWeight', 'bold');
    end
    % Title: 12 pt bold
    if ~isempty(ax.Title.String)
        set(ax.Title, 'FontSize', 12, 'FontWeight', 'bold');
    end
end

% --- Colorbars ---
cbs = findall(fig, 'Type', 'colorbar');
for i = 1:numel(cbs)
    set(cbs(i), 'FontWeight', 'bold', 'FontSize', 10);
    if isprop(cbs(i), 'Label') && ~isempty(cbs(i).Label.String)
        set(cbs(i).Label, 'FontWeight', 'bold', 'FontSize', 11);
    end
end

% --- Legends ---
legs = findall(fig, 'Type', 'legend');
for i = 1:numel(legs)
    set(legs(i), 'FontSize', 9);
end
end
