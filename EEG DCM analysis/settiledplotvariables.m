function [title_font_size, title_fontweight, plot_linewidth, ticklength, axis_linewidth, marker_size, tick_fontsize, ylabel_fontsize] = settiledplotvariables(scale_factor)
    % Default value for scale_factor
    if nargin < 1
        scale_factor = 1;
    end

    % Variables for plotting neural population response in tiles
    title_font_size = 18.5 * scale_factor;
    title_fontweight = 'bold';
    plot_linewidth = 4;
    ticklength = [0.02 0.025];
    axis_linewidth = 2;
    marker_size = 8;
    tick_fontsize = 18 * scale_factor;
    ylabel_fontsize = 18 * scale_factor;
end
