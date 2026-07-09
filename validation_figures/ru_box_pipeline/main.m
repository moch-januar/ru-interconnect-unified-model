function main(repoRoot, manuscriptRoot, varargin)
%MAIN Entry point for Ru BOX figure pipeline.
% This is a thin wrapper around ru_box_pipeline_main().

ru_box_pipeline_main(repoRoot, manuscriptRoot, varargin{:});
end
