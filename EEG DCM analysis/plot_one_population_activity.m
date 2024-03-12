function [tcl, ax] = plot_one_population_activity(tclMain, tcl, ax, axgrid, source_vector, pop_index, state_values, DCM, grand_average_flag, upper_x_limit, condition_number, scenario, show_XTicklabel)
%plot_one_population_activity plotting the neural activity of one
%population from DCM files
%   ns:                 Vector of source numbers
%   nt:                 Number of trials
%   pop_index:          vector of population indeces
%   population_names:   cell of state names
%   state_values:       m x n matrix of the values of state variables
%   DCM:                DCM estimated model
%   axgrid              Number of rows and columns in the tiled grid
alpha = 95;
trial_name = DCM.xY.code;
limits_for_time = [-50 upper_x_limit(condition_number)];
ns = size(DCM.Sname, 2);
nt  = length(DCM.xY.y);
% show_XTicklabel = 1;    % shows the tick of the last tile

num_of_sources_in_vector = length(source_vector);

% while num_of_sources_in_vector < axgrid(1)                          % create figures with same tile size
%     num_of_sources_in_vector = num_of_sources_in_vector + 1;
%     source_vector(num_of_sources_in_vector) = source_vector(1);
% end
    

[~,~, ~, ~, num_of_source_in_figure, ~, ~] = mainfigure_variables();
[population_names, response_dimension, population_number] = load_population_names();

scale_factor = 1;
[title_font_size, title_fontweight, plot_linewidth, ticklength, axis_linewidth, marker_size, tick_fontsize, ylabel_fontsize] = settiledplotvariables(scale_factor);  % loading tiled plot variables
variables = load_scenario_variable(scenario);

color_of_line = variables.color_of_line;
lighter_color_of_line = variables.lighter_color_of_line;

if grand_average_flag
    linewidth = plot_linewidth;
    K = state_values(condition_number, ~cellfun('isempty',state_values(condition_number,:)));
else
    K = state_values(~cellfun('isempty',state_values));
    linewidth = plot_linewidth * 0.6;
    linestyle = "--";
end

K_condition = cell(1, 2);

if condition_number == 2 && grand_average_flag
    for all_conditions = 1 : size(state_values, 1)
        K_tmp = state_values(all_conditions, ~cellfun('isempty',state_values(all_conditions,:)));
        K_condition{all_conditions} = calculateKInTrial(source_vector, nt, K_tmp, ns, pop_index);
    end
end
    


    
if grand_average_flag    
    K_in_trial = calculateKInTrial(source_vector, nt, K, ns, pop_index);
    % integrated_data.K_condition{condition_number} = K_in_trial;
    % integrated_data.trial_name{condition_number} = trial_name;
end


% tcl = gobjects(1,axgrid(1));
% ax = gobjects(axgrid); 

% figure_handle = figure;
row_tile_num = 0;
for source_index = 1 : num_of_source_in_figure
    if source_index <= length(source_vector)
        i = source_vector(source_index);
        str   = {};
        row_tile_num = row_tile_num + 1;
        if condition_number == 1 && grand_average_flag == 0
            tcl(row_tile_num) = tiledlayout(tclMain,1,axgrid(2), "TileSpacing", 'tight');
        end
        tcl(row_tile_num).Layout.Tile = row_tile_num;
    
    
    %     hold on
        for k = 1:nt
            for population = pop_index
                column_tile_num = find(population == pop_index);
                
                if condition_number == 1 && grand_average_flag == 0
                    ax(row_tile_num, column_tile_num) = nexttile(tcl(row_tile_num));
                else
                    axes(ax(row_tile_num, column_tile_num))
                    hold on
                end


                % Set common properties for all plots
                set(ax(row_tile_num, column_tile_num), 'FontSize', tick_fontsize, 'LineWidth', axis_linewidth, 'TickDir', 'out', 'TickLength', ticklength);
                ytickformat(ax(row_tile_num, column_tile_num), '%.1f');
                xlim(limits_for_time)
                % Remove x-tick labels for all but the last row
                if (source_index < num_of_source_in_figure && show_XTicklabel) || ~show_XTicklabel
                    % xticklabels(ax(row_tile_num, column_tile_num), repmat({' '}, size(ax(row_tile_num, column_tile_num).XTick))); % Replace labels with spaces

                    set(ax(row_tile_num, column_tile_num), 'XTickLabel', {});
                end

                if grand_average_flag
                    str{1} = sprintf([trial_name{k} ' - averaged']);
                    str{2} = sprintf([trial_name{k} ' - 95%% CI']);
                    hold on
                    if condition_number == 2
                        plotCI(DCM.xY.pst, K_in_trial{k, i, population}, ...
                            alpha, color_of_line{condition_number}, lighter_color_of_line{condition_number}, linewidth, str, K_condition{1}{k, i, population}, K_condition{2}{k, i, population});
                    else
                        plotCI(DCM.xY.pst, K_in_trial{k, i, population}, ...
                            alpha, color_of_line{condition_number}, lighter_color_of_line{condition_number}, linewidth, str, K_condition{1}, K_condition{2});
                    end
    
        %             set(gca,'linewidth',axis_linewidth, 'TickLength',ticklength);
                
        %                 str{end + 1} = sprintf([DCM.xY.code{k} ' - averaged over participants']);
                else
                    str = sprintf([trial_name{k} ' - best fitted participant']);
                    plot(DCM.xY.pst, K{k}(:,i + ns*(population - 1)), ...
                        'LineWidth',2, 'LineStyle', linestyle ,'color', color_of_line{condition_number},'linewidth', linewidth, 'DisplayName', str);
                    hold on
        %                 str{end + 1} = sprintf([DCM.xY.code{k} ' - best fitted participant']);
                end
                % if i == source_vector(end) && show_XTicklabel == 1
                %     xlim(limits_for_time)
                %     set(ax(row_tile_num, column_tile_num),'FontSize',tick_fontsize,'LineWidth',axis_linewidth,'TickDir','out',...
                %         'TickLength',ticklength);                    
                % else
                %     set(ax(row_tile_num, column_tile_num),'FontSize',tick_fontsize,'LineWidth',axis_linewidth,'TickDir','out',...
                %         'TickLength',ticklength, 'Xticklabel',[]);
                % end
    
                box(ax(row_tile_num, column_tile_num), 'off')
                ylabel(response_dimension{population}, 'fontsize', ylabel_fontsize)
                
            end
            title(tcl(row_tile_num),[DCM.Sname{i}], 'FontSize', title_font_size, 'fontweight',title_fontweight)
    %         title([DCM.Sname{i}], 'FontSize', title_font_size, 'fontweight',title_fontweight);
            
        end
    else
        % Increase the row tile number for the empty plot
        row_tile_num = row_tile_num + 1;
        if condition_number == 1 && grand_average_flag == 0
            tcl(row_tile_num) = tiledlayout(tclMain, 1, axgrid(2));
            tcl(row_tile_num).Layout.Tile = row_tile_num;
        end
        for column_num = 1 : length(pop_index)
            % Create a new tile for the empty plot
            if condition_number == 1 && grand_average_flag == 0
                ax(row_tile_num, column_num) = nexttile(tcl(row_tile_num)); 
            else
                % For the existing layout
                % ax(row_tile_num, 1) = axes('Parent', figure_handle); 
            end
            
            % Set properties for the empty plots
            xlim(limits_for_time)
            % ylim([-1 1])
            set(ax(row_tile_num, column_num), 'FontSize', tick_fontsize, 'LineWidth', axis_linewidth, 'TickDir', 'out', 'TickLength', ticklength, 'Color', 'none', 'XColor', 'black', 'YColor', 'none', 'XTickMode', 'auto', 'XTickLabelMode', 'auto', 'Box', 'off');
            ytickformat(ax(row_tile_num, column_num), '%.1f');
            % Hide the y-axis
            % set(ax(row_tile_num, column_num), 'YTickLabel', [], 'YTick', []);
    
            % Ensure x-axis is visible
            set(ax(row_tile_num, column_num), 'XAxisLocation', 'bottom');
    
            % Add an invisible row title
            title(tcl(row_tile_num), 'Invisible Row Title', 'Visible', 'off', 'FontSize', title_font_size, 'fontweight',title_fontweight);
    
            % Invisible ylabel
            ylabel(ax(row_tile_num, column_num), response_dimension{population},'fontsize', ylabel_fontsize, 'Visible', 'off');
            
        end
    end

end


% legend(str, 'Location', 'southoutside');

