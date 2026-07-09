function generate_vlsi2026_box_sets(varargin)
%GENERATE_VLSI2026_BOX_SETS Compatibility wrapper for full local box-set generation.
%
% This keeps the legacy entrypoint name from matlab_notgood while running the
% self-contained Manuscript1_Transport/MatlabCode pipelines.

run_exact_box_set_figures(varargin{:});
end
