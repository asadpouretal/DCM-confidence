function [title_fontweight, lable_fontsize, lable_fontweight, legend_fontsize, num_of_source_in_figure, column_title_position, show_xlabel, scale_factor] = mainfigure_variables(option)
%mainfigure_variables Assign main figure variables
%   If no input is provided, it keeps default values.
%   If input is 'highlow', num_of_source_in_figure is set to 4.
%   If input is 'fastslow', num_of_source_in_figure is set to 3.

% Default values
scale_factor = 1;
title_fontweight = 'bold';
lable_fontsize = 24 * scale_factor;
lable_fontweight = 'normal';
legend_fontsize = 18 * scale_factor;
num_of_source_in_figure = 4; % default value
column_title_position = [0 -0.858 0 0];
show_xlabel = 1;

% Check for optional input argument and adjust num_of_source_in_figure
if nargin == 1 % Check if one input argument is provided
    if strcmp(option, 'highlow')
        num_of_source_in_figure = 4;
    elseif strcmp(option, 'fastslow')
        num_of_source_in_figure = 3;
        column_title_position = [0 -0.855 0 0];
    end
end
end
