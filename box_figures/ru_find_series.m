function [ps, color, label, found] = ru_find_series(series, name, style)
% RU_FIND_SERIES Locate a series by name with safe fallbacks.

ps = struct();
color = style.colors.deepBlue;
label = name;
found = false;

for k = 1:numel(series)
    if strcmp(series(k).name, name)
        ps = series(k).ps;
        color = series(k).color;
        label = series(k).label;
        found = true;
        return;
    end
end
end
