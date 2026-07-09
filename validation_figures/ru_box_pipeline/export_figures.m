function export_figures(figs, outDir, opt)
%EXPORT_FIGURES Export each box as vector PDF + high-DPI PNG.

names = fieldnames(figs);
for i = 1:numel(names)
    nm = names{i};
    f = figs.(nm);

    pdfPath = fullfile(outDir, sprintf('Fig_%s.pdf', nm));
    pngPath = fullfile(outDir, sprintf('Fig_%s.png', nm));

    if ~isgraphics(f)
        warning('Skipping %s: not a valid graphics handle.', nm);
        continue;
    end

    % Normalize to a figure handle (exportgraphics support differs by release).
    if strcmp(get(f, 'Type'), 'figure')
        figHandle = f;
    else
        figHandle = ancestor(f, 'figure');
    end

    if isempty(figHandle) || ~isgraphics(figHandle)
        warning('Skipping %s: could not resolve a parent figure.', nm);
        continue;
    end

    set(figHandle, 'InvertHardcopy', 'off');

    % Prefer exportgraphics; fallback to print for compatibility.
    try
        exportgraphics(figHandle, pdfPath, 'ContentType', 'vector', 'BackgroundColor', 'white');
    catch
        print(figHandle, pdfPath, '-dpdf', '-painters');
    end

    try
        exportgraphics(figHandle, pngPath, 'Resolution', opt.EXPORT_DPI, 'BackgroundColor', 'white');
    catch
        print(figHandle, pngPath, '-dpng', sprintf('-r%d', opt.EXPORT_DPI));
    end
end
end
