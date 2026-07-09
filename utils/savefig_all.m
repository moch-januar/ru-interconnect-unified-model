function savefig_all(figHandle, fullPath)

if isnumeric(figHandle) || isa(figHandle, 'matlab.ui.Figure')
    [outDir, baseName, ~] = fileparts(fullPath);
elseif ischar(figHandle)
    baseName = figHandle;
    if nargin < 2 || isempty(fullPath)
        outDir = 'figures';
    else
        outDir = fullPath;
    end
    figHandle = gcf;
end

if isempty(outDir)
    outDir = '.';
end

ensure_dir(outDir);

pdfPath = fullfile(outDir, [baseName, '.pdf']);
pngPath = fullfile(outDir, [baseName, '.png']);

figure(figHandle);

preferredFont = 'CMU Serif';
fallbackFont  = 'Arial';

availableFonts = string(listfonts);
if any(strcmpi(availableFonts, preferredFont))
    useFont = preferredFont;
else
    useFont = fallbackFont;
end

set(findall(figHandle, '-property', 'FontName'), 'FontName', useFont);

set(figHandle, 'Renderer', 'painters');

try
    exportgraphics(figHandle, pdfPath, 'ContentType', 'vector');
catch
    exportgraphics(figHandle, pdfPath, 'ContentType', 'image', 'Resolution', 300);
end

exportgraphics(figHandle, pngPath, 'Resolution', 300);

end
