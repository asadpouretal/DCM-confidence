function plotNeuralCorrelations(timePoints, regionNames, sourceNames, behaviorType, conditionName, showLegend)
    % Define the colors for each neural population using hexadecimal color codes
    colors = {[0, 0, 0], [0, 0.4470, 0.7410], [0.8500, 0.3250, 0.0980], [0.9290, 0.6940, 0.1250]};
    xlimits = [150 400];
    tiledplotvariables;
    lineWidth = 3;
    markerSize = marker_size;
    zoom_scale = 1;
    ticklength = [0.008, 0.025];
    % Define markers for positive and negative correlations
    markers = {'x', 'o'};
    
    % Define background colors based on behavior type with fainter colors
    if strcmp(behaviorType, 'Confidence Rating')
        bgColor = [0.9, 0.95, 0.9]; % A fainter soft green
    elseif strcmp(behaviorType, 'Reaction Time')
        bgColor = [0.95, 0.9, 0.95]; % A fainter soft purple
    else
        bgColor = [1, 1, 1]; % Default to white if behavior type is unrecognized
    end
    
    % Create the figure with a specific size
    fig = figure('Name',conditionName);
    fig.Units = 'normalized';
    fig.Position = [0.1, 0.1, 0.5, 0.8]; % Normalized position [left, bottom, width, height]
    % Create tiled layout
    t = tiledlayout(length(regionNames), 1, 'TileSpacing', 'compact', 'Padding', 'compact');
    
    % Create the main title with additional space above
    mainTitleText = ['Neural Correlation with ', behaviorType];
    halfLineSpace = ['\fontsize{4}{}', newline]; % Smaller font size for half-line space
    mainTitle = title(t, [mainTitleText, halfLineSpace], 'FontSize', 16, 'FontWeight', 'normal');

    
    % Loop over each brain region
    for i = 1:length(regionNames)
        % Create a subplot for each brain region using tiledlayout
        ax = nexttile;
        hold on; % Hold on to the current subplot
        
        % Set the background color for the subplot
        set(ax, 'Color', bgColor);
        
        % Loop over each neural population
        for j = 1:size(timePoints, 2)
            % Extract the time points for the current neural population and region
            currentTimes = timePoints{i, j};
            % Loop over each time point
            for time_index = 1:length(currentTimes)
                % Check if the time point is positive or negative for the marker type
                time = currentTimes(time_index);
                markerType = markers{(time < 0) + 1};
                % Plot the time point with the appropriate marker and color
                plot(ax, abs(time), j, markerType, 'Color', colors{j}, 'MarkerSize', 10, 'HandleVisibility','off','LineWidth', lineWidth, 'MarkerSize', markerSize);
            end
        end
        
        % Set the y-axis limits and labels
        ylim(ax, [0.5, size(timePoints, 2) + 0.5]);
        xlim(ax, xlimits);
        set(ax, 'ytick', [], 'TickDir', 'out');
        set(ax, 'FontSize', zoom_scale * tick_fontsize, 'LineWidth', zoom_scale *  axis_linewidth, 'TickLength', zoom_scale * ticklength); % Set font size
        if i ~= length(regionNames)
            set(ax, 'yticklabel', [], 'xticklabel', []);
        end
        
        % Set the brain region name as the title of each tile
        title(ax, regionNames{i}, 'FontSize', 14,'FontWeight', 'Normal');
    end
    
    % Set the x-axis limits and labels for the last tile
    lastAx = gca; % Get the current (last) axes
    xlabel(t, 'Time from stimulus onset (ms)', 'FontSize', 18);
    set(lastAx, 'xtick', xlimits(1):50:xlimits(2),'TickDir', 'out'); % Corrected this line
    set(lastAx, 'FontSize', 12); % Set font size for the last tile

    % Create a legend for the neural populations using lines
    for j = 1:length(colors)
        plot(lastAx, NaN, NaN, '-', 'Color', colors{j}, 'DisplayName', sourceNames{j}, 'LineWidth', 2);
    end

    % Add entries for positive and negative correlations to the legend
    plot(lastAx, NaN, NaN, 'x', 'Color', [0.5, 0.5, 0.5], 'DisplayName', 'Pos. Corr.', 'LineWidth', 2);  % Gray color
    plot(lastAx, NaN, NaN, 'o', 'Color', [0.5, 0.5, 0.5], 'DisplayName', 'Neg. Corr.', 'LineWidth', 2);  % Gray color

    % Place the legend in the best location outside the tiled layout
    lgd = legend(lastAx, 'show');
    set(lgd, 'Location', 'southoutside', 'Orientation', 'horizontal', 'FontSize', 12, 'Color', [1, 1, 1]);
    if ~showLegend
        lgd.Visible = 'off';
    end


    hold off; % Release the figure
end
