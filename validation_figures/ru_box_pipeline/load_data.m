function raw = load_data(repoRoot, datasetName)
%LOAD_DATA Load Ru resistivity dataset for box figures.
%
% Expected dataset formats:
%   - CSV with columns: x,y (nm, uOhm*cm)
%   - CSV with columns: Thickness_nm, Resistivity_uOhmcm (names flexible)

if nargin < 2 || strlength(string(datasetName)) == 0
    datasetName = 'Ru-interconnect_rho_vs_thickness_fitted.csv';
end

% Priority 1: local data/ folder next to this pipeline (self-contained mode).
%   Resolves to  MatlabCode/data/<name>  regardless of repoRoot.
thisPipelineDir = fileparts(mfilename('fullpath'));          % ru_box_pipeline/
matlabCodeDir   = fileparts(fileparts(thisPipelineDir));    % MatlabCode/
localPath = fullfile(matlabCodeDir, 'data', char(datasetName));

% Priority 2: original external convention  <repoRoot>/Papers/extracted_data/<name>
externalPath = fullfile(repoRoot, 'Papers', 'extracted_data', char(datasetName));

if exist(localPath, 'file')
    datasetPath = localPath;
elseif exist(externalPath, 'file')
    datasetPath = externalPath;
else
    error(['Dataset not found in either location:' newline ...
           '  Local   : %s' newline ...
           '  External: %s' newline ...
           'Place the CSV in MatlabCode/data/ to run self-contained.'], ...
          localPath, externalPath);
end

[~, ~, ext] = fileparts(datasetPath);
raw = struct();
raw.sourcePath = datasetPath;

switch lower(ext)
    case '.csv'
        T = readtable(datasetPath, 'PreserveVariableNames', true);
        vars = lower(string(T.Properties.VariableNames));

        % Most common in this repo: x,y
        ix = find(vars == "x", 1);
        iy = find(vars == "y", 1);
        if ~isempty(ix) && ~isempty(iy)
            raw.thickness_nm = T{:, ix};
            raw.rho_uohmcm = T{:, iy};
            raw.meta = struct('format', 'xy');
            return;
        end

        % Flexible: thickness and resistivity columns
        ith = find(contains(vars, "thickness") | contains(vars, "width") | contains(vars, "t_nm"), 1);
        irho = find(contains(vars, "rho") | contains(vars, "resist"), 1);
        if isempty(ith) || isempty(irho)
            error('Could not infer columns in %s. Found: %s', datasetPath, strjoin(cellstr(vars), ', '));
        end

        raw.thickness_nm = T{:, ith};
        raw.rho_uohmcm = T{:, irho};
        raw.meta = struct('format', 'inferred', 'thicknessVar', T.Properties.VariableNames{ith}, 'rhoVar', T.Properties.VariableNames{irho});

    otherwise
        error('Unsupported dataset extension: %s', ext);
end
end
