function draw_band(x0, y0, band, color, label)
    patch([x0+band(1) x0+band(2) x0+band(2) x0+band(1)], [y0-0.06 y0-0.06 y0+0.06 y0+0.06], color, 'FaceAlpha',0.25, 'EdgeColor', color, 'LineWidth',1.5);
    text(0.02,y0, label, 'FontWeight','bold');
    text(x0+band(2)+0.02,y0, sprintf('R=[%.2f, %.2f]', band(1), band(2)), 'FontWeight','bold','FontSize',8);
end