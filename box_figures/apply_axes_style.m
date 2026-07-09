
function apply_axes_style(fig, style)
    axs = findall(fig, 'Type','axes');
    for i = 1:numel(axs)
        ax = axs(i);
        ax.FontName   = style.fontName;
        ax.FontSize   = style.fontSizeAxis;
        ax.FontWeight = 'bold';
        ax.LineWidth  = 2;
        ax.Box        = 'on';
        ax.GridAlpha  = style.gridAlpha;
        if ~strcmp(ax.XLabel.String,'')
            ax.XLabel.FontWeight = 'bold';
            ax.XLabel.FontName   = style.fontName;
        end
        if ~strcmp(ax.YLabel.String,'')
            ax.YLabel.FontWeight = 'bold';
            ax.YLabel.FontName   = style.fontName;
        end
    end
    
    legs = findall(fig, 'Type','legend');
    for i = 1:numel(legs)
        lg          = legs(i);
        lg.FontName = style.fontName;
        lg.FontSize = style.fontSizeLegend;
        lg.Box      = 'off';
    end
end