function plot_average_significant_trial_DCM_activity(significant_population_in_condition, plot_window, scenario_variable)
    % Color-blind friendly colors
    colors = [0, 0, 0; 0, 0.4470, 0.7410; 0.8500, 0.3250, 0.0980; 0.9290, 0.6940, 0.1250; 0.4940, 0.1840, 0.5560; 0.4660, 0.6740, 0.1880; 0.3010, 0.7450, 0.9330];

    % Font and line settings
    fontName = 'Arial';
    fontSize = 12;
    
    
    [title_fontweight,lable_fontsize, lable_fontweight, legend_fontsize, ~, ~, ~, scale_factor] = mainfigure_variables();
    tiledplotvariables;
    lineWidth = plot_linewidth;
    markerSize = marker_size;
    zoom_scale = 2;
    % Get the screen size
    screen_size = get(0, 'ScreenSize');
    fig_width = screen_size(3) / 2;
    fig_height = screen_size(4) / 2;


    % Loop through each structure in significant_population_in_condition
    for i = scenario_variable %1:length(significant_population_in_condition)
        behavior_data = significant_population_in_condition{i};
        behavior = behavior_data.Behavior;
        condition_name = behavior_data.ConditionName;
        concatenated_source_activity = behavior_data.concatenated_source_activity;
        t = round(behavior_data.t);
        actual_sequences = behavior_data.ActualSequences;
        source_names = behavior_data.SourceNames;
        population_names = behavior_data.PopulationNames;
        comparing_trial_names = behavior_data.comparing_trial_names;

        % Find the indices corresponding to the plot window
        plot_window = round(plot_window);
        t_start_index = find(t >= plot_window(1), 1, 'first');
        t_end_index = find(t <= plot_window(2), 1, 'last');

        % Loop through each row in concatenated_source_activity (each source)
        [m, p] = size(concatenated_source_activity);
        for row = 1:m
            % Create a new figure and set its size
            hFig = figure('Position', [1, 1, fig_width, fig_height]);
            
            hold on;

            % Initialize legends
            legends = {};
            legend_handles = [];

            % Loop through each cell in concatenated_source_activity (each population)
            for col = 1:p
                activity_cell = concatenated_source_activity{row, col};
                if ~isempty(activity_cell)
                    for k = 1:length(activity_cell)
                        activity_matrix = activity_cell{k};
                        if ~isempty(activity_matrix)
                            % Extract the data within the plot window
                            plot_data = activity_matrix(t_start_index:t_end_index, :);

                            % Calculate the mean and 95% confidence interval over trials
                            mean_activity = mean(plot_data, 2);
                            ci_upper = prctile(plot_data, 97.5, 2);
                            ci_lower = prctile(plot_data, 2.5, 2);
                            
                            figure(hFig);

                            % Plot the 95% confidence interval as a shaded area
                            fill([t(t_start_index:t_end_index), fliplr(t(t_start_index:t_end_index))], ...
                                 [ci_upper', fliplr(ci_lower')], ...
                                 colors(col, :), 'EdgeColor', 'none', 'FaceAlpha', 0.2);

                            % Plot the mean activity and save the handle for the legend
                            if k == 1
                                h = plot(t(t_start_index:t_end_index), mean_activity, 'Color', colors(col, :), 'LineWidth', lineWidth, 'HandleVisibility','off');
                            else
                                h = plot(t(t_start_index:t_end_index), mean_activity, 'Color', colors(col, :), 'LineWidth', lineWidth, 'LineStyle', '--', 'HandleVisibility','off');
                            end

                            % Plot the 'x' and 'o' corresponding to ActualSequences
                            for a_seq = cell2mat(actual_sequences{row, col})
                                if ~isempty(a_seq)
                                    for v = 1:length(a_seq)
                                        val = a_seq(v);
                                        index = find(t(t_start_index:t_end_index) == abs(round(val)));
                                        if ~isempty(index)
                                            if val >= 0
                                                plot(t(t_start_index - 1 + index), mean_activity(index), 'x', 'Color', colors(col, :), 'LineWidth', lineWidth, 'MarkerSize', markerSize, 'HandleVisibility','off');
                                            else
                                                plot(t(t_start_index - 1 + index), mean_activity(index), 'o', 'Color', colors(col, :), 'LineWidth', lineWidth, 'MarkerSize', markerSize, 'HandleVisibility','off');
                                            end
                                        end
                                    end
                                end
                            end

                            % Add population name to legends only once
                            if k == 1
                                legends{end + 1} = population_names{col};
                                legend_handles(end + 1) = h;
                                hZoomFig = figure('Position', [1, 1, 1.1 *fig_height, fig_height]);
                                hold on
                            else
                                figure(hZoomFig);
                            end
                            % Create separate figures for zoomed-in views
                            % Create a new figure for zoomed-in view
                            actual_sequences_temp = cell2mat(actual_sequences{row, col});
                            zoom_start_index = min(find(t == abs(round(actual_sequences_temp(1)))), find(t == abs(round(actual_sequences_temp(end))))) - 5;
                            zoom_end_index = max(find(t == abs(round(actual_sequences_temp(1)))), find(t == abs(round(actual_sequences_temp(end))))) + 5;
                            zoom_start_index = max(zoom_start_index, t_start_index);
                            zoom_end_index = min(zoom_end_index, t_end_index);
                            zoom_data = activity_matrix(zoom_start_index:zoom_end_index, :);
                            mean_zoom_activity = mean(zoom_data, 2);

                            ci_upper = prctile(zoom_data, 97.5, 2);
                            ci_lower = prctile(zoom_data, 2.5, 2);

                            % Plot the 95% confidence interval as a shaded area
                            fill([t(zoom_start_index:zoom_end_index), fliplr(t(zoom_start_index:zoom_end_index))], ...
                                 [ci_upper', fliplr(ci_lower')], ...
                                 colors(col, :), 'EdgeColor', 'none', 'FaceAlpha', 0.2);

                            % Plot the mean activity and save the handle for the legend
                            if k == 1
                                hz = plot(t(zoom_start_index:zoom_end_index), mean_zoom_activity, 'Color', colors(col, :), 'LineWidth', 2 * lineWidth, 'HandleVisibility','off');
                            else
                                hz = plot(t(zoom_start_index:zoom_end_index), mean_zoom_activity, 'Color', colors(col, :), 'LineWidth', 2 * lineWidth, 'LineStyle', '--', 'HandleVisibility','off');
                            end

                            for a_seq = cell2mat(actual_sequences{row, col})
                                if ~isempty(a_seq)
                                    % Determine indices for zoomed-in view
                                    for v = 1:length(a_seq)
                                        val = a_seq(v);
                                        index = find(t(zoom_start_index:zoom_end_index) == abs(round(val)));
                                        if ~isempty(index)
                                            if val >= 0
                                                plot(t(zoom_start_index - 1 + index), mean_zoom_activity(index), 'x', 'Color', colors(col, :), 'LineWidth', 2 * lineWidth, 'MarkerSize', zoom_scale * markerSize, 'HandleVisibility','off');
                                            else
                                                plot(t(zoom_start_index - 1 + index), mean_zoom_activity(index), 'o', 'Color', colors(col, :), 'LineWidth', 2 * lineWidth, 'MarkerSize', zoom_scale * markerSize, 'HandleVisibility','off');
                                            end
                                        end
                                    end
                                end

                            end
                            xlim([t(zoom_start_index) t(zoom_end_index)]);
                            if min(mean_zoom_activity) < 0 && max(mean_zoom_activity) < 0
                                ylim([1.1 * min(mean_zoom_activity) 0.9 * max(mean_zoom_activity)]);
                            else
                                ylim([0.9 * min(mean_zoom_activity)  1.1 * max(mean_zoom_activity)]);
                            end
                            ax_z = gca;
                            set(ax_z, 'Box', 'off');
                            set(ax_z, 'TickDir', 'out');
                            set(ax_z, 'FontName', fontName);
                            set(ax_z, 'FontSize', zoom_scale * tick_fontsize, 'LineWidth', zoom_scale *  axis_linewidth, 'TickLength', zoom_scale * ticklength);
                            title(['Zoomed in: ', condition_name, ' - ', source_names{row}], 'FontName', fontName, 'FontSize', fontSize);
                            if isempty(legend_handles)
                                close(hZoomFig);
                            end
                        end
                    end
                    % ... [additional code for handling markers 'x' and 'o'] ...
                end
            end
            % Adjust the y-axis limits of hFig
            figure(hFig);  % Ensure that hFig is the current figure
            currentYLim = get(gca, 'YLim');  % Get the current y-axis limits

            % Check if the minimum mean activity is less than -0.5
            if min(currentYLim) < -0.5
                maxAbsYLim = max(abs(currentYLim));  % Find the maximum absolute value of current y-axis limits
                set(gca, 'YLim', [-maxAbsYLim, maxAbsYLim]);  % Set symmetric y-axis limits
            end

            % Plot the lines for comparing_trial_names legends
            h1 = plot(NaN, NaN, 'Color', [0.5 0.5 0.5], 'LineWidth', lineWidth, 'HandleVisibility','off');
            h2 = plot(NaN, NaN, 'Color', [0.5 0.5 0.5], 'LineWidth', lineWidth, 'LineStyle', '--', 'HandleVisibility','off');

            if ~isempty(legend_handles)
                title([condition_name, ' - ', source_names{row}], 'FontName', fontName, 'FontSize', fontSize);
                xlabel('Time from stimulus onset (ms)', 'FontName', fontName, 'FontSize', fontSize);
                ylabel('Voltage (a.u.)', 'FontName', fontName, 'FontSize', fontSize);
                l = legend([legend_handles, h1, h2], [legends, comparing_trial_names{1}, comparing_trial_names{2}], 'Location', 'Best', 'FontName', fontName, 'FontSize', fontSize);
                % l = legend([legend_handles], [legends], 'Location', 'Best', 'FontName', fontName, 'FontSize', fontSize);
                set(l, 'Box', 'off');
                ax = gca;
                set(ax, 'Box', 'off');
                set(ax, 'TickDir', 'out');
                set(ax, 'FontName', fontName);
                set(ax, 'FontSize', tick_fontsize, 'LineWidth', axis_linewidth, 'TickLength', ticklength);
            else
                close(hFig);                
            end
        end
    end
end