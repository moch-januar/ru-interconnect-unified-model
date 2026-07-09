function generate_ru_dft_comprehensive(params, fig_dir, cfg)
%% GENERATE_RU_DFT_COMPREHENSIVE Integrated 6-panel Ru analysis

    fig = figure('Color','w', 'Position', [50 50 1600 1000]);
    
    w = logspace(log10(2e-9), log10(100e-9), 200);
    
    tiledlayout(3, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
    
    %% Panel (a): Resistivity with all texture cases
    nexttile;
    
    params_tex = params; params_tex.metals(1).R0 = params.metals(1).R0_textured;
    params_con = params; params_con.metals(1).R0 = params.metals(1).R0_conventional;
    params_spu = params; params_spu.metals(1).R0 = params.metals(1).R0_sputtered;
    
    rho_tex = arrayfun(@(wi) rho_ru_helper(wi, 0, params_tex, 1), w);
    rho_con = arrayfun(@(wi) rho_ru_helper(wi, 0, params_con, 1), w);
    rho_spu = arrayfun(@(wi) rho_ru_helper(wi, 0, params_spu, 1), w);
    
    loglog(w*1e9, rho_tex*1e8, 'LineWidth', 3, 'Color', [0.22 0.42 0.65]);
    hold on;
    loglog(w*1e9, rho_con*1e8, '--', 'LineWidth', 2, 'Color', [0.85 0.55 0.10]);
    loglog(w*1e9, rho_spu*1e8, ':', 'LineWidth', 2, 'Color', [0.65 0.15 0.15]);
    hold off;
    legend('Textured <001>', 'Conventional', 'Sputtered', 'Location', 'northwest', 'FontSize', 10);
    xlabel('Linewidth (nm)', 'FontWeight', 'bold');
    ylabel('Resistivity (μΩ·cm)', 'FontWeight', 'bold');
    title('(a) Texture-Dependent Resistivity', 'FontWeight', 'bold');
    grid on; box on;
    set(gca, 'FontSize', 11, 'LineWidth', 1.2);
    
    %% Panel (b): Phase comparison
    nexttile;
    
    rho_hcp = arrayfun(@(wi) rho_ru_helper(wi, 0, params, 1), w);
    
    params_fcc = params;
    params_fcc.metals(1).kF = params.metals(1).kF * 1.05;
    params_fcc.metals(1).lambda = params.metals(1).lambda * 0.95;
    rho_fcc = arrayfun(@(wi) rho_ru_helper(wi, 0, params_fcc, 1), w);
    
    loglog(w*1e9, rho_hcp*1e8, 'LineWidth', 2.5, 'Color', [0.22 0.42 0.65]);
    hold on;
    loglog(w*1e9, rho_fcc*1e8, '--', 'LineWidth', 2.5, 'Color', [0.85 0.33 0.10]);
    xline(params.metals(1).phase_crossover_thickness*1e9, ':', 'LineWidth', 1.5, 'Color', [0.5 0.5 0.5]);
    hold off;
    legend('hcp (bulk)', 'fcc (thin-film)', 'Phase crossover', 'Location', 'northwest', 'FontSize', 10);
    xlabel('Linewidth (nm)', 'FontWeight', 'bold');
    ylabel('Resistivity (μΩ·cm)', 'FontWeight', 'bold');
    title('(b) DFT Phase Comparison', 'FontWeight', 'bold');
    grid on; box on;
    set(gca, 'FontSize', 11, 'LineWidth', 1.2);
    
    %% Panel (c): Liner comparison
    nexttile;
    
    t_liner = [0, 1e-9, 2e-9];
    colors = [0.2 0.2 0.2; 0.85 0.55 0.10; 0.65 0.15 0.15];
    
    for j = 1:length(t_liner)
        rho_liner = arrayfun(@(wi) rho_ru_helper(wi, t_liner(j), params, 1), w);
        loglog(w*1e9, rho_liner*1e8, 'LineWidth', 2.5, 'Color', colors(j,:), ...
            'DisplayName', sprintf('t_{liner} = %.1f nm', t_liner(j)*1e9));
        hold on;
    end
    hold off;
    legend('Location', 'northwest', 'FontSize', 10);
    xlabel('Linewidth (nm)', 'FontWeight', 'bold');
    ylabel('Resistivity (μΩ·cm)', 'FontWeight', 'bold');
    title('(c) Liner Thickness Impact', 'FontWeight', 'bold');
    grid on; box on;
    set(gca, 'FontSize', 11, 'LineWidth', 1.2);
    
    %% Panel (d): Quantum crossover
    nexttile;
    
    w_fine = linspace(2e-9, 30e-9, 500);
    rho_quantum = arrayfun(@(wi) rho_ru_helper(wi, 0, params, 1), w_fine);
    
    % Compute classical for comparison
    params_noquant = params;
    params_noquant.metals(1).wq = 0;  % Disable quantum
    rho_classical = arrayfun(@(wi) rho_ru_helper(wi, 0, params_noquant, 1), w_fine);
    
    plot(w_fine*1e9, rho_quantum*1e8, 'LineWidth', 2.5, 'Color', [0.22 0.42 0.65]);
    hold on;
    plot(w_fine*1e9, rho_classical*1e8, '--', 'LineWidth', 2, 'Color', [0.7 0.7 0.7]);
    xline(params.metals(1).wq*1e9, ':', 'LineWidth', 2, 'Color', [0.85 0.33 0.10], ...
        'DisplayName', sprintf('w_q = %.1f nm', params.metals(1).wq*1e9));
    hold off;
    legend('With quantum', 'Classical only', 'Quantum onset', 'Location', 'northwest', 'FontSize', 10);
    xlabel('Linewidth (nm)', 'FontWeight', 'bold');
    ylabel('Resistivity (μΩ·cm)', 'FontWeight', 'bold');
    title('(d) Quantum Confinement Onset', 'FontWeight', 'bold');
    grid on; box on;
    xlim([2 30]);
    set(gca, 'FontSize', 11, 'LineWidth', 1.2);
    
    %% Panel (e): Temperature dependence
    nexttile;
    
    T_sweep = 250:25:450;
    w_test = [7e-9, 10e-9, 15e-9, 20e-9];
    colors_T = [0.22 0.42 0.65; 0.55 0.35 0.65; 0.85 0.33 0.10; 0.85 0.55 0.10];
    
    for j = 1:length(w_test)
        rho_T = zeros(size(T_sweep));
        for i = 1:length(T_sweep)
            params_T = params;
            params_T.T = T_sweep(i);
            rho_T(i) = rho_ru_helper(w_test(j), 0, params_T, 1);
        end
        plot(T_sweep, rho_T*1e8, 'LineWidth', 2.5, 'Color', colors_T(j,:), ...
            'DisplayName', sprintf('w = %.0f nm', w_test(j)*1e9));
        hold on;
    end
    hold off;
    legend('Location', 'northwest', 'FontSize', 10);
    xlabel('Temperature (K)', 'FontWeight', 'bold');
    ylabel('Resistivity (μΩ·cm)', 'FontWeight', 'bold');
    title(sprintf('(e) Temperature Dependence (TCR = %.4f K^{-1})', params.metals(1).alpha_TCR), ...
        'FontWeight', 'bold');
    grid on; box on;
    set(gca, 'FontSize', 11, 'LineWidth', 1.2);
    
    %% Panel (f): Current density limits
    nexttile;
    
    J = logspace(6, 7.5, 100);
    w_em = [7e-9, 10e-9, 15e-9];
    
    % Simplified EM lifetime (Black's equation proxy)
    for j = 1:length(w_em)
        MTTF_relative = (J/1e6).^(-2);  % Simplified: MTTF ∝ J^-2
        
        semilogy(J/1e6, MTTF_relative, 'LineWidth', 2.5, ...
            'DisplayName', sprintf('w = %.0f nm', w_em(j)*1e9));
        hold on;
    end
    
    % Add thermal runaway threshold
    J_thermal = 8e6;  % Approximate from TCR
    xline(J_thermal/1e6, '--', 'Thermal runaway', 'LineWidth', 2, 'Color', [0.85 0.15 0.15]);
    
    hold off;
    legend('Location', 'northeast', 'FontSize', 10);
    xlabel('Current Density (MA/cm²)', 'FontWeight', 'bold');
    ylabel('Relative MTTF (a.u.)', 'FontWeight', 'bold');
    title(sprintf('(f) Reliability Limits (E_a = %.1f eV)', params.metals(1).E_a_EM), ...
        'FontWeight', 'bold');
    grid on; box on;
    set(gca, 'FontSize', 11, 'LineWidth', 1.2);
    
    savefig_all('Ru_DFT_Comprehensive_Analysis', fig_dir);
    
end
