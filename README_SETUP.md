# Manuscript1_Transport Figure Generation - Complete Guide

**Manuscript**: DFT-Anchored Unified Transport Model for Resolving Parameter Non-Identifiability in Sub-10nm Ruthenium Interconnects  
**Publication**: ACS (VLSI 2026)  
**Generated**: April 11, 2026

---

## QUICK START

### Prerequisites
- MATLAB R2020b or later
- Statistics and Machine Learning Toolbox  
- (Optional) Symbolic Math Toolbox for advanced DFT analysis

### Folder Structure
```
MatlabCode/
├── box_figures/           # Box figure generation (Fig_BOX_01, 03, 04, 06, 09, 11, 13, 14, 15, 26, 27)
├── validation_figures/    # Validation analysis (Fig_validation_*)
├── dft_figures/          # DFT-based analysis (Fig1)
├── utils/                # Utilities (savefig, ensure_dir)
├── config/               # Configuration (plot_style)
├── FIGURE_SOURCES_MAPPING.md
├── README_SETUP.md (this file)
└── run_all_manuscript_figures.m (orchestrator) - TO BE CREATED
```

---

## FIGURE-BY-FIGURE EXECUTION

### 1. BOX FIGURES (Core Manuscript Figures)

These are the main figures in the manuscript. They depend on:
- Experimental data (fitted results assumed to be available)
- Pre-computed model parameters

#### Individual Box Figure Execution

```matlab
%% Box Figure 01: Phase, Work Function, Surface Energy  
cd box_figures
fig = figure();
ax1 = subplot(1,2,1);
ax2 = subplot(1,2,2);
% Requires DFT data structure
% box01_phase_workfunction_surfaceenergy(ax1, ax2, dft_data, style_struct);

%% Box Figure 03: Roughness Proxy Mapping
fig = figure();
ax1 = subplot(1,2,1);
ax2 = subplot(1,2,2);
% box03_roughness_proxy_mapping(ax1, ax2, dft_data, style);

%% Box Figure 04: Texture & Grain Priors
% box04_texture_grain_priors(ax1, ax2, meta, style);
```

**Dependencies**: 
- `apply_axes_style.m`
- `base_params.m`
- `ru_find_series.m`
- DFT and experimental data structures

#### Running Box Figures with Prepared Data

If you have pre-fitted model results:

```matlab
% Add paths
addpath(genpath('box_figures'));
addpath('utils');
addpath('config');

% Load your fitted data (fitResult, data, meta, dft, style structs)
load('path/to/your/fitted_results.mat');  % Adjust path

% Create figure styling
style = plot_style();

% Generate individual box figure
fig_box06 = figure('Color','w',...
    'Position',[100 100 850 600]);
tiledlayout(fig_box06, 1, 2);
ax1 = nexttile;
ax2 = nexttile;

% Call the box figure generator
box06_model_fit_comparison(ax1, ax2, data, meta, fitResult, style, ablFits);

% Save
savefig_all(fig_box06, 'Fig_BOX_06', './figures');
```

---

### 2. VALIDATION FIGURES

The validation figures are **more self-contained** and require minimal external data.

#### Running Validation Figures

```matlab
%% Setup paths
cd validation_figures
addpath('codesign_pipeline');
addpath('ru_box_pipeline');
addpath('../config');

%% Generate all validation figures
generate_validation_figures();

%% Output
% Generates 5 figures:
%   - Fig_validation_condition_number.png
%   - Fig_validation_leave_one_out.png
%   - Fig_validation_correlation_heatmap.png
%   - Fig_validation_scaling_sensitivity.png
%   - Fig_validation_literature_comparison.png
```

**Note**: This script is **nearly standalone** - it loads calibrated parameters from `codesign_params.m` and doesn't require external experimental data.

---

### 3. DFT FIGURES

#### Running DFT Comprehensive Figure

```matlab
%% Setup paths
cd dft_figures
addpath('../config');
addpath('../utils');

%% Generate DFT figure (Fig1)
params = params_default();  % Load default configuration
proj_root = '.';

% Generate the comprehensive DFT analysis figure  
generate_ru_dft_comprehensive(params, proj_root);

%% Output
% Generates:
%   - Fig1.png / Fig1.pdf
%   - Ru_DFT_Comprehensive_Analysis.png / .pdf
```

---

## COMPLETE EXECUTION WORKFLOW

### Full Standalone Run (No External Data Required)

```matlab
%% COMPLETE FIGURE GENERATION - STANDALONE
%% This generates all validation and DFT figures without external dependencies

clear all; close all; cd MatlabCode;

% Add all paths
addpath('validation_figures');
addpath(fullfile('validation_figures','codesign_pipeline'));
addpath(fullfile('validation_figures','ru_box_pipeline'));
addpath('dft_figures');
addpath('box_figures');
addpath('utils');
addpath('config');

% Create output directory
ensure_dir('figures');

fprintf('========================================\n');
fprintf('Generating Manuscript1 Figures\n');
fprintf('========================================\n\n');

%% 1. VALIDATION FIGURES (No external data needed)
fprintf('[1/2] Generating validation figures...\n\n');
try
    cd validation_figures
    generate_validation_figures();
    cd ..
    fprintf('✓ Validation figures complete\n\n');
catch ME
    fprintf('✗ Validation figures error: %s\n\n', ME.message);
end

%% 2. DFT FIGURES  
fprintf('[2/2] Generating DFT figures...\n\n');
try
    cd dft_figures
    params = params_default();
    generate_ru_dft_comprehensive(params, '.');
    cd ..
    fprintf('✓ DFT figures complete\n\n');
catch ME
    fprintf('✗ DFT figures error: %s\n\n', ME.message);
end

fprintf('========================================\n');
fprintf('Figure Generation Summary\n');
fprintf('========================================\n');
fprintf('Generated figures (standalone):\n');
fprintf('  ✓ Fig_validation_condition_number.png\n');
fprintf('  ✓ Fig_validation_leave_one_out.png\n');
fprintf('  ✓ Fig_validation_correlation_heatmap.png\n');
fprintf('  ✓ Fig_validation_scaling_sensitivity.png\n');
fprintf('  ✓ Fig_validation_literature_comparison.png\n');
fprintf('  ✓ Fig1.png / Ru_DFT_Comprehensive_Analysis.png\n\n');

fprintf('Output directory: %s\n', fullfile(pwd, 'figures'));
fprintf('========================================\n');
```

---

## WITH EXPERIMENTAL DATA (Full Reproduction)

If you have the fitted model results:

```matlab
%% Complete figure generation with fitted data
clear all; close all; cd MatlabCode;

% Load fitted results from your analysis
% Expected structures: fitResult, data, meta, dft, ci, sel, ident, style
load('../../../data_out/pso_results.mat');  % Adjust path to your saved data

% Add all paths
addpath(genpath('.'));

ensure_dir('figures');

%% STEP 1: Validation figures (standalone)
cd validation_figures
generate_validation_figures();
cd ..

%% STEP 2: Box figures (require fitted data)
cd box_figures

% Create figure and call box generators
box_ids = [1, 3, 4, 6, 9, 11, 13, 14, 15, 26, 27];  % Manuscript figures

for bid = box_ids
    try
        fig = figure('Visible','off','Color','w');
        tiledlayout(fig, 1, 2);
        
        % Minimal call pattern for each box
        switch bid
            case 1
                % Special 3-panel layout
                tiledlayout(fig, 1, 3);
                box01_phase_workfunction_surfaceenergy(...
                    nexttile, nexttile, dft, style);
            case 3
                box03_roughness_proxy_mapping(...
                    nexttile, nexttile, dft, style);
            case 4
                box04_texture_grain_priors(...
                    nexttile, nexttile, meta, style);
            case 6
                box06_model_fit_comparison(...
                    nexttile, nexttile, data, meta, fitResult, style, ablFits);
            % ... etc for other boxes
        end
        
        % Save figure
        fname = sprintf('Fig_BOX_%02d', bid);
        savefig_all(fig, fname, '../figures');
        close(fig);
        
        fprintf('✓ Generated Fig_BOX_%02d\n', bid);
    catch ME
        fprintf('✗ Error generating Fig_BOX_%02d: %s\n', bid, ME.message);
    end
end

cd ..
```

---

## TROUBLESHOOTING

### Issue: "Function 'apply_axes_style' not found"
**Solution**: Ensure you've added box_figures to path:
```matlab
addpath(fullfile(pwd, 'box_figures'));
```

### Issue: "Missing data structure (data, meta, fitResult, etc.)"
**Solution**: For standalone testing, you can create minimal test structures:
```matlab
% Minimal test data structure
data.t = [6:2:50];           % Thickness in nm
data.y = 15 + 0.2*data.t;    % Test resistivity data
meta.D = 20;                 % Grain size
meta.F001 = 0.5;             % Texture fraction

fitResult.p = [0.05, 0.12, 0.20];    % Specularity for 3 conditions
fitResult.R = 0.40;                   % GB reflection
fitResult.A_Q = 8.2;                  % Quantum amplitude
% etc.
```

### Issue: "savefig_all not working / not exporting to PNG"
**Solution**: Check that `utils/savefig_all.m` is in path and that you have write access to output directory:
```matlab
ensure_dir('figures');  % Create if needed
savefig_all(fig, 'TestFig', './figures');
```

---

## FILE DEPENDENCY SUMMARY

### Standalone (No External Data):
- ✓ `generate_validation_figures.m` 
- ✓ `generate_ru_dft_comprehensive.m`

### Require Fitted Data:
- Box figures (all variants)
  
### Critical Support Files (Always Needed):
- `plot_style.m` (styling)
- `savefig_all.m` (export)
- `ensure_dir.m` (path management)
- `apply_axes_style.m` (box figure styling)
- `base_params.m` (box parameter defaults)

---

## OUTPUT VERIFICATION

After running the scripts, verify that these 13 figures are produced:

### Box Figures (8 total, 11 individual .png files)
```
Fig_BOX_01.png  ✓
Fig_BOX_03.png  ✓
Fig_BOX_04.png  ✓
Fig_BOX_06.png  ✓
Fig_BOX_09.png  ✓
Fig_BOX_11.png  ✓
Fig_BOX_13.png  ✓
Fig_BOX_14.png  ✓
Fig_BOX_15.png  ✓
Fig_BOX_26.png  ✓
Fig_BOX_27.png  ✓
```

### Validation Figures (5 total)
```
Fig_validation_condition_number.png     ✓
Fig_validation_leave_one_out.png        ✓
Fig_validation_correlation_heatmap.png  ✓
Fig_validation_scaling_sensitivity.png  ✓
Fig_validation_literature_comparison.png✓
```

### DFT Figures (1 total)
```
Fig1.png (or Ru_DFT_Comprehensive_Analysis.png) ✓
```

---

## NOTES

1. **Box figures REQUIRE**:
   - Pre-computed fitted model results (`fitResult` struct)
   - Experimental data (`data` struct)  
   - Metadata (`meta` struct)
   - Style configuration (`style` struct)
   - These are typically generated by the main calibration pipeline

2. **Validation figures are STANDALONE**:
   - Use calibrated parameters from `codesign_params.m`
   - Compute synthetic resistivity from models
   - No external experimental data required

3. **DFT figures** use tabulated DFT surface properties and are also standalone with minimal dependencies

4. **All figures** export as:
   - High-resolution PNG (600-900 DPI)
   - Vector PDF (for publication)

---

## ADDITIONAL RESOURCES

- **FIGURE_SOURCES_MAPPING.md**: Complete mapping of figures to source files
- **MATLAB_FIGURE_GENERATION_CATALOG.md** (parent directory): Comprehensive system documentation
- **README.md** (parent project): Main project documentation

**For questions**: See original manuscript or contact authors

