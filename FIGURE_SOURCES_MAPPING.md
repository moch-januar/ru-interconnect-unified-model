# Manuscript Figure Generation - Source Code Mapping
**Manuscript**: Manuscript_JMCC.tex  
**Generated**: April 11, 2026

---

## FIGURE-TO-SOURCE MAPPING

### Primary Figures (13 Total)

| Figure Name | Type | Source File(s) | Original Path |
|-------------|------|---|---|
| **Fig1.png** | DFT facet statistics | `generate_ru_dft_comprehensive.m` | `RuDFT_Analysis/scripts/` |
| **Fig_BOX_01.png** | Phase, work function, surface energy | `box01_phase_workfunction_surfaceenergy.m` | `ru_resistivity_boxes/plots/` |
| **Fig_BOX_03.png** | Roughness proxy mapping | `box03_roughness_proxy_mapping.m` | `ru_resistivity_boxes/plots/` |
| **Fig_BOX_04.png** | Texture & grain priors | `box04_texture_grain_priors.m` | `ru_resistivity_boxes/plots/` |
| **Fig3_tall.png** | Resistivity scaling + quantum | Identified in validation pipeline | TBD |
| **Fig_BOX_06.png** | Model fit comparison (FS vs MS) | `box06_model_fit_comparison.m` | `ru_resistivity_boxes/plots/` |
| **Fig_BOX_09.png** | Quantum ablation study | `box09_quantum_ablation.m` | `ru_resistivity_boxes/plots/` |
| **Fig_BOX_11.png** | Multi-condition fits | `box11_multicondition_fit.m` | `ru_resistivity_boxes/plots/` |
| **Fig_BOX_13.png** | Extracted parameters | `box13_extracted_params.m` | `ru_resistivity_boxes/plots/` |
| **Fig_BOX_14.png** | Design space (ρ vs thickness) | `box14_design_space.m` | `ru_resistivity_boxes/plots/` |
| **Fig_BOX_15.png** | Optimization trade-off | `box15_optimization_tradeoff.m` | `ru_resistivity_boxes/plots/` |
| **Fig_BOX_26.png** | Bandwidth-reliability trade-off | `box26_bandwidth_reliability.m` | `ru_resistivity_boxes/plots/` |
| **Fig_BOX_27.png** | Grain texture effect | `box27_grain_texture_effect.m` | `ru_resistivity_boxes/plots/` |
| **Fig_validation_leave_one_out.png** | Cross-validation | `generate_validation_figures.m` | `Papers.VLSI2026/matlab_notgood/` |
| **Fig_validation_condition_number.png** | Parameter identifiability | `generate_validation_figures.m` | `Papers.VLSI2026/matlab_notgood/` |
| **Fig_validation_correlation_heatmap.png** | Parameter correlation matrix | `generate_validation_figures.m` | `Papers.VLSI2026/matlab_notgood/` |
| **Fig_validation_literature_comparison.png** | Literature parameter values | `generate_validation_figures.m` | `Papers.VLSI2026/matlab_notgood/` |
| **Fig_validation_scaling_sensitivity.png** | Sensitivity hierarchy | `generate_validation_figures.m` | `Papers.VLSI2026/matlab_notgood/` |

---

## FILE ORGANIZATION IN MatlabCode/

```
MatlabCode/
├── box_figures/
│   ├── box01_phase_workfunction_surfaceenergy.m
│   ├── box03_roughness_proxy_mapping.m
│   ├── box04_texture_grain_priors.m
│   ├── box06_model_fit_comparison.m
│   ├── box09_quantum_ablation.m
│   ├── box11_multicondition_fit.m
│   ├── box13_extracted_params.m
│   ├── box14_design_space.m
│   ├── box15_optimization_tradeoff.m
│   ├── box26_bandwidth_reliability.m
│   ├── box27_grain_texture_effect.m
│   ├── apply_axes_style.m (support)
│   ├── base_params.m (support)
│   ├── pick_fit.m (support)
│   ├── plot_one_condition_fit.m (support)
│   ├── ru_find_series.m (support)
│   └── ru_plot_series.m (support)
│
├── validation_figures/
│   ├── generate_validation_figures.m (MAIN)
│   ├── plot_condition_number_comparison.m
│   ├── plot_leave_one_out_validation.m
│   ├── plot_parameter_correlation_heatmap.m
│   ├── plot_scaling_sensitivity.m
│   ├── plot_literature_comparison.m
│   ├── export_all_figures.m (support)
│   ├── compute_fisher_condition_numbers.m
│   └── [...other helper functions...]
│
├── dft_figures/
│   ├── generate_ru_dft_comprehensive.m (MAIN for Fig1)
│   ├── rho_ru_helper.m (support)
│   └── [...related DFT utilities...]
│
├── utils/
│   ├── savefig_all.m
│   ├── ensure_dir.m
│   └── [...other utilities...]
│
├── config/
│   ├── plot_style.m
│   └── params_default.m
│
├── models/
│   ├── objective_resistance.m (if needed)
│   ├── rho_*_*.m (various resistivity models)
│   └── [...physics models...]
│
├── FIGURE_SOURCES_MAPPING.md (this file)
├── README_SETUP.md
└── run_all_manuscript_figures.m (orchestrator)
```

---

## DEPENDENCIES & REQUIRED DATA

### External Data Files Needed:
- Experimental data from Leem IEDM 2025
- Calibrated parameters (codesign_params.m)
- DFT surface properties
- Fitted model results

### Key Dependencies Between Figures:
- All Box figures depend on: `apply_axes_style.m`, `base_params.m`
- Box01 depends on: DFT data structures
- Box06, Box09, Box11, Box13 depend on: experimental data + fitted model
- Validation figures depend on: calibrated parameters + Fisher information

---

## EXECUTION PRIORITY

### Critical Path (Must Copy First):
1. **Box figures** (box_figures/*.m) - Lowest dependencies
2. **Validation figures** - Medium dependencies  
3. **DFT figures** - Medium dependencies
4. **Support files** (utils/, config/, models/)

### Build Order:
1. Copy **box_figures/** and all support utilities
2. Copy **validation_figures/** with all helpers
3. Copy **dft_figures/** 
4. Set up data paths
5. Run individual figure generators
6. Run orchestration script

---

## NOTES

- **matlab_notgood directory**: This is NOT a failed code repository - it contains specialized validation and proposal-specific figures. These are correct codes.
- **Box figure naming**: Fig_BOX_01, Fig_BOX_03, etc. (not sequential - only manuscript-used figures)
- **Data dependencies**: Box figures require pre-computed fitted results (fitResult struct)
  - Consider: May need to regenerate from sweep_runner or load from saved cache
- **Standalone mode**: Some figures can run standalone; others require full ecosystem

---

## VALIDATION STRATEGY

For each figure group:
1. ✓ Copy files preserving directory structure
2. ✓ Check file integrity (no corruption)
3. ✓ Fix path references (relative → absolute as needed)
4. ✓ Run individual generators with test data
5. ✓ Verify output matches manuscript figures

