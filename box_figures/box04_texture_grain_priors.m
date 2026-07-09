function box04_texture_grain_priors(ax1, ax2, meta, style)
    axes(ax1);
    conds = {'Conventional Ru','Sputtered Ru','Textured Ru'};
    D = [meta.micro.conventional_ALD_Ru.D_nm, meta.micro.sputtered_Ru.D_nm, meta.micro.textured_ALD_Ru.D_nm];
    F = [meta.micro.conventional_ALD_Ru.F001_pct, meta.micro.sputtered_Ru.F001_pct, meta.micro.textured_ALD_Ru.F001_pct];
    leftColor = style.colors.teal;       % grain size
    rightColor = style.colors.warmOrange; % texture fraction
    
    yyaxis left;
    bar(categorical(conds), D, 'FaceColor', leftColor, 'EdgeColor', style.colors.charcoal, 'LineWidth', 1.0);
    ylabel('Grain size, D (nm)','FontWeight','bold'); axis tight;
    ylim([-10,110]);
    ax = gca;
    ax.YColor = leftColor;
    
    yyaxis right;
    plot(1:3, F, '-o', 'Color', rightColor, 'LineWidth', style.lineWidth, 'MarkerSize', style.markerSize, 'MarkerFaceColor', rightColor);
    ylabel('F_{001} (%)','FontWeight','bold');
    title('          (c) Ru Microstructures (Leem et al., IEDM 2025)','FontWeight','bold');
    grid on; alpha(0.4);
    ylim([-10,110]);
    ax = gca;
    ax.YColor = rightColor;
    
    % === Right panel: GB-type R prior bands ===
    % === Right panel: R prior intervals (meaningful plot) ===
axes(ax2);
cla;
hold on;

% Turn it into a real axis (not "axis off")
xlim([0 1.2]);
ylim([0.5 3.5]);
box on;
grid on;
set(gca, 'YDir','reverse');  % top item first
set(gca, 'YTick', [1 2 3], 'YTickLabel', {'Conventional','Sputtered','Textured'});
set(gca, 'FontWeight','bold');

title('(d) Grain-Boundary Reflection', 'FontWeight','bold');
xlabel('GB reflection coefficient, R', 'FontWeight','bold');

% Extract priors
R_conv = meta.priors.R.conventional_ALD_Ru;
R_sput = meta.priors.R.sputtered_Ru;
R_text = meta.priors.R.textured_ALD_Ru;

% Pack
Rall   = [R_conv; R_sput; R_text];
labels = {'Conventional Ru','Sputtered Ru','Textured Ru'};
ypos   = [1 2 3];

% Colors
edgeCols = [style.colors.crimson; style.colors.warmOrange; style.colors.deepBlue];
fillCols = [0.93 0.75 0.75; 0.96 0.88 0.74; 0.78 0.84 0.95];

bandH = 0.28;      % thickness of interval band
capH  = 0.20;      % cap size for errorbar-like ends
lwBand = 8;        % thick interval (looks clean)
lwEdge = 2.2;

for i = 1:3
    r1 = Rall(i,1);
    r2 = Rall(i,2);
    rc = 0.5*(r1+r2);

    % Thick band (interval)
    plot([r1 r2], [ypos(i) ypos(i)], '-', ...
        'Color', fillCols(i,:), 'LineWidth', lwBand);

    % Crisp edge overlay
    plot([r1 r2], [ypos(i) ypos(i)], '-', ...
        'Color', edgeCols(i,:), 'LineWidth', lwEdge);

    % End caps (like errorbar caps)
    plot([r1 r1], [ypos(i)-capH ypos(i)+capH], '-', 'Color', edgeCols(i,:), 'LineWidth', lwEdge);
    plot([r2 r2], [ypos(i)-capH ypos(i)+capH], '-', 'Color', edgeCols(i,:), 'LineWidth', lwEdge);

    % Midpoint marker
    plot(rc, ypos(i), 'o', ...
        'MarkerSize', 8, 'MarkerFaceColor', edgeCols(i,:), ...
        'MarkerEdgeColor', style.colors.charcoal, 'LineWidth', 1.0);

    % Text annotation
    txt = sprintf('[%.2f, %.2f]', r1, r2);
    text(min(r2+0.03, 0.98), ypos(i), txt, ...
        'FontWeight','bold', 'FontSize', 10, ...
        'VerticalAlignment','middle', 'HorizontalAlignment','left');
end

% Add an interpretation strip at the bottom (physics meaning)
% Low R -> CSL/low-angle; High R -> random/non-CSL
yStrip = 3.35;
nStrip = 120;
xs = linspace(0.02, 0.98, nStrip);
for k = 1:nStrip-1
    t = (k-1)/(nStrip-1);
    % subtle gradient from cool (low-R) to warm (high-R)
    col = (1-t)*[0.78 0.84 0.95] + t*[0.96 0.88 0.74];
    plot([xs(k) xs(k+1)], [yStrip yStrip], '-', 'Color', col, 'LineWidth', 6);
end
text(0.05, yStrip-0.7, 'Low R: CSL / low-angle GBs', ...
    'FontSize', 9.5, 'FontWeight','bold', 'HorizontalAlignment','left');
text(1.15, yStrip-2.0, 'High R: random / non-CSL GBs', ...
    'FontSize', 9.5, 'FontWeight','bold', 'HorizontalAlignment','right');

% Tidy axis look
set(gca, 'YMinorTick','off', 'XMinorTick','off');
set(gca, 'LineWidth', 1.2);


end
