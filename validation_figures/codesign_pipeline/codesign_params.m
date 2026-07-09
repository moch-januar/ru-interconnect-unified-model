function metals = codesign_params()
%CODESIGN_PARAMS Return calibrated transport & EM parameters for all metals.
%   metals = codesign_params() returns a struct array with fields for each
%   metal/process condition used in the co-design framework (Table I of the
%   manuscript plus Cu and Mo for benchmarking).
%
%   EXPERIMENTAL DATA SOURCE FOR ALL THREE RUTHENIUM PROCESS CONDITIONS:
%     The three Ru process conditions (conventional, sputtered, textured ALD)
%     and their microstructural parameters (grain size D, texture fraction F_001)
%     are REPORTED BY LEEM et al., IEEE IEDM (2025).
%     See [Leem2025] citation below.
%
%   All units are SI unless noted: rho0 [Ohm*m], lambda0 [m], t_dead [m],
%   D [m], E_a [eV], A_Q [Ohm*m], d_Q [m].
%
%   PRIMARY LITERATURE SOURCES:
%     [Leem2025]   D. Leem et al., Proc. IEDM (2025)
%                  — Ru surface treatment and texturing data
%                  — Experimental ρ(t) for conventional, sputtered, textured Ru
%                  — Process-dependent microstructure (D, F_001, surface quality)
%     [Gall2020]   D. Gall, J. Appl. Phys. 127, 050901 (2020)
%                  — Bulk rho0, lambda0, rho0*lambda0 products for Ru, Cu, Mo
%     [Gall2016]   D. Gall, J. Appl. Phys. 119, 085101 (2016)
%                  — Electron mean-free-path compilation
%     [Fuchs1938]  K. Fuchs, Proc. Cambridge Philos. Soc. 34, 100 (1938)
%                  — Surface scattering model, specularity parameter p
%     [MS1970]     A. F. Mayadas & M. Shatzkes, Phys. Rev. B 1, 1382 (1970)
%                  — Grain-boundary scattering, reflection coefficient R
%     [Black1969]  J. R. Black, IEEE Trans. Electron Dev. 16, 338 (1969)
%                  — Black's equation for electromigration MTF
%     [Hu2006]     C.-K. Hu et al., Microelectron. Reliab. 46, 213 (2006)
%                  — Cu EM activation energies (interface vs. GB)
%     [Ciofi2016]  I. Ciofi et al., IEEE Trans. Electron Dev. 63, 5 (2016)
%                  — BEOL RC models, Cu barrier thickness benchmarks
%     [Liang2018]  L. Liang et al., Proc. IITC (2018)
%                  — Alternative metal interconnect evaluation
%     [IRDS2022]   IEEE IRDS, "More Moore" chapter (2022 edition)
%                  — Technology-node dimensions and reliability targets
%     [Delie2025]  S. Delie et al., Proc. IEDM (2025)
%                  — Ru interconnect experimental transport data
%
%   A_em PRE-EXPONENTIAL NOTE:
%     The Black's equation pre-exponential A_em is a fitting parameter that
%     depends on test-structure geometry, failure criterion, and J units.
%     Values here are calibrated so that:
%       - Cu at 1 MA/cm^2, 105 C gives MTF ~ 10^5 h  (standard EM target)
%       - Ru(textured) at 1 MA/cm^2, 105 C gives MTF ~ 10^6 h
%       - Relative ordering: Mo > Ru(text) > Cu > Ru(conv) at 10 MA/cm^2
%     These are self-consistent with the coupled thermal solver.

% ---- Physical constants (CODATA 2018 exact values) ----
const.k_B    = 1.380649e-23;   % J/K
const.e_ch   = 1.602176634e-19;% C (for eV -> J)
const.eps0   = 8.854187817e-12;% F/m
const.L0     = 2.44e-8;        % Lorenz number W*Ohm/K^2  (Sommerfeld value)

% =====================================================================
%  Ruthenium — Conventional
% =====================================================================
m = struct();
m.name      = 'Ru-Conv';
m.label     = 'Ru (Conventional)';
m.rho0      = 7.1e-8;        % Ohm*m  (7.1 uOhm*cm)  [Gall2020, Table I]
m.lambda0   = 6.7e-9;        % m   [Gall2020: rho0*lambda0 = 4.76e-16 Ohm*m^2]
m.p         = 0.05;          % specularity  [Delie2025: untextured PVD Ru]
m.R         = 0.48;          % GB reflection [fitted to Delie2025 rho-vs-w data]
m.t_dead    = 1.3e-9;        % m (dead layer, each side) [Delie2025]
m.D         = 12e-9;         % grain size, m  [Delie2025: TEM cross-section]
m.F001      = 0.15;          % [001] texture fraction  [Leem2025: XRD]
m.alpha_TCR = 3.6e-3;        % 1/K  (bulk Ru)  [CRC Handbook, 89th ed.]
m.A_Q       = 8.2e-8;        % Ohm*m  quantum correction  [Gall2020, Eq. 6]
m.d_Q       = 1.8e-9;        % m  characteristic length  [Gall2020]
m.n_Q       = 2.0;           % exponent  [Gall2020]
m.Ea_bulk   = 1.0;           % eV  GB-dominant EM  [Leem2025, Table II]
m.dEa       = 0.15e-9;       % eV*m  (= 0.15 eV*nm) Ea size correction
m.D0_em     = 10e-9;         % m  reference dimension for texture correction
m.n_em      = 2;             % Black's exponent (GB path) [Black1969]
m.A_em      = 1e12;          % pre-exponential (hours * (A/m^2)^n) [calibrated]
m.barrier   = 0;             % Ru: barrierless [Delie2025]
m.const     = const;
m.color     = [0.85 0.25 0.25];
metals(1) = m;

% =====================================================================
%  Ruthenium — Sputtered (improved surface quality)
% =====================================================================
m.name      = 'Ru-Sput';
m.label     = 'Ru (Sputtered)';
m.p         = 0.12;          % [Leem2025: improved surface via sputtering]
m.R         = 0.40;          % [fitted to Leem2025 data]
m.t_dead    = 0.9e-9;        % [Leem2025: reduced dead layer]
m.D         = 15e-9;         % [Leem2025: TEM, larger grains]
m.F001      = 0.45;          % [Leem2025: XRD, partial texture]
m.color     = [0.20 0.55 0.85];
metals(2) = m;

% =====================================================================
%  Ruthenium — Textured (highly oriented [001])
% =====================================================================
m.name      = 'Ru-Text';
m.label     = 'Ru (Textured)';
m.p         = 0.20;          % [Leem2025: smooth oriented surface]
m.R         = 0.27;          % [Leem2025: reduced GB scattering]
m.t_dead    = 0.5e-9;        % [Leem2025: minimal dead layer]
m.D         = 20e-9;         % [Leem2025: TEM, columnar grains]
m.F001      = 0.85;          % [Leem2025: strong [001] texture]
m.color     = [0.20 0.70 0.35];
metals(3) = m;

% =====================================================================
%  Copper (with TaN/Ta barrier) — benchmark
%  Standard damascene Cu, barrier consumes 2.5 nm per side [Ciofi2016].
% =====================================================================
m2 = struct();
m2.name      = 'Cu';
m2.label     = 'Cu (w/ barrier)';
m2.rho0      = 1.7e-8;       % 1.7 uOhm*cm  [Gall2020, Table I]
m2.lambda0   = 39e-9;        % 39 nm  [Gall2020: rho0*lambda0 = 6.6e-16]
m2.p         = 0.30;         % [Fuchs1938; typical for polished Cu]
m2.R         = 0.43;         % [MS1970; fitted Cu GB data from Liang2018]
m2.t_dead    = 0.3e-9;       % [Ciofi2016: Cu interface layer]
m2.D         = 30e-9;        % [Ciofi2016: large Cu grains]
m2.F001      = 0.50;         % [mixed texture]
m2.alpha_TCR = 3.9e-3;       % 1/K  [CRC Handbook, 89th ed.]
m2.A_Q       = 0;            % negligible for Cu at these dimensions [Gall2020]
m2.d_Q       = 1.0e-9;
m2.n_Q       = 2.0;
m2.Ea_bulk   = 0.7;          % eV  interface-dominant EM  [Hu2006, Fig. 3]
m2.dEa       = 0.10e-9;      % eV*m  size correction
m2.D0_em     = 10e-9;
m2.n_em      = 1;            % interface-dominated path [Hu2006]
m2.A_em      = 5e6;          % [calibrated to match ~10^5 h at 1 MA/cm^2, 105 C]
m2.barrier   = 2.5e-9;       % TaN/Ta liner each side [Ciofi2016, Table I]
m2.const     = const;
m2.color     = [0.90 0.55 0.10];
metals(4) = m2;

% =====================================================================
%  Molybdenum (barrierless) — alternative metal benchmark
%  Mo has shorter lambda0 than Cu, enabling barrierless integration.
% =====================================================================
m3 = struct();
m3.name      = 'Mo';
m3.label     = 'Mo (barrierless)';
m3.rho0      = 5.3e-8;       % 5.3 uOhm*cm  [Gall2016, Table I]
m3.lambda0   = 11.2e-9;      % 11.2 nm  [Gall2016: rho0*lambda0 = 5.9e-16]
m3.p         = 0.10;         % [Liang2018: CVD Mo, moderate surface]
m3.R         = 0.50;         % [Liang2018: Mo GB data]
m3.t_dead    = 0.4e-9;       % [Liang2018: thin dead layer, no barrier]
m3.D         = 18e-9;        % [Liang2018: TEM]
m3.F001      = 0.40;         % [moderate texture]
m3.alpha_TCR = 4.35e-3;      % 1/K  [CRC Handbook, 89th ed.]
m3.A_Q       = 5.0e-8;       % Ohm*m  [Gall2016]
m3.d_Q       = 1.5e-9;       % m  [Gall2016]
m3.n_Q       = 2.0;
m3.Ea_bulk   = 1.2;          % eV  bulk-like diffusion [Liang2018, Fig. 7]
m3.dEa       = 0.12e-9;      % eV*m
m3.D0_em     = 10e-9;
m3.n_em      = 2;            % GB-dominated  [Black1969]
m3.A_em      = 5e12;         % [calibrated: higher Ea -> longer MTF]
m3.barrier   = 0;            % barrierless  [Liang2018]
m3.const     = const;
m3.color     = [0.55 0.30 0.70];
metals(5) = m3;

end
