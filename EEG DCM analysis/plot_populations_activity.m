function plot_populations_activity(scenario, save_flag)
%plot_populations_activity plots population activity
% populations to draw specified in load_population_name.m
% scenario variables loaded from load_scenario_variable.m
close all;
variables = load_scenario_variable(scenario);
condition_vector = [1 2];

for condition_number = condition_vector
     clearvars -except condition_number figures str main_tiled_figures tcl ax condition_vector scenario save_flag variables figure1 whole_K integrated_data
    
    GCM_fullname = variables.GCM_fullname;
    BMS_fullfile = variables.BMS_fullfile;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Assign main variables
    winning_model_number = variables.winning_model_number;
    [population_names, ~, population_number] = load_population_names();
    string_to_find = 'sub-';    % string to find the actual subject number
    upper_x_limit = [500 500]; % in ms
    grand_average_flag = 1;
    trial_number = 1;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Assign figure variables

    [title_fontweight,lable_fontsize, lable_fontweight, legend_fontsize, num_of_source_in_figure, column_title_position, show_xlabel] = mainfigure_variables();
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % load model space files
    load(BMS_fullfile{condition_number});
    index = find([BMS.DCM.rfx.bma.Mocc{:}] == winning_model_number(condition_number));                    % finding subjects with optimum model being the winning model


    load(GCM_fullname{condition_number});
    GCM = data.GCM;

        % DCM best fitted participant
    number_of_best_DCM(condition_number) = find_best_participant(GCM_fullname{condition_number}, winning_model_number(condition_number), index);
    
    for DCM_number = index
        idx_of_subject_number = strfind(GCM{DCM_number,winning_model_number(condition_number)}, string_to_find) + length(string_to_find);
        actual_subject_numbers(DCM_number) = str2num(GCM{DCM_number,winning_model_number(condition_number)}(idx_of_subject_number: idx_of_subject_number + 1));
        load(GCM{DCM_number,winning_model_number(condition_number)});

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Calculate neural activity matrix in the source space (K) for each participant
        [K, ns, nt] = cal_neural_activity(DCM);
        % scale = DCM.xY.scale; 
        % for i = 1 : length(K)
        %     K{i} = K{i} ./ scale; % Scale back to the original values
        % end
        subject(DCM_number).K = K;  % storing neural activity (source space) converted to its actual scale
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Integrate neural activity of all optimum subjects in one cell
    phase_name{condition_number} = DCM.xY.code{trial_number};
    if ~exist('whole_K', 'var')
        whole_K = cell(length(subject(index(1)).K), length(index));
    end
    for trial_number = 1 : length(subject(index(1)).K)    
        for subject_num = index
            whole_K{condition_number, subject_num} = subject(subject_num).K{trial_number};
        end
    end
end

for condition_number = condition_vector
     clearvars -except condition_number figures str main_tiled_figures tcl ax condition_vector scenario save_flag variables figure1 whole_K
    
    GCM_fullname = variables.GCM_fullname;
    BMS_fullfile = variables.BMS_fullfile;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Assign main variables
    winning_model_number = variables.winning_model_number;
    [population_names, ~, population_number] = load_population_names();
    string_to_find = 'sub-';    % string to find the actual subject number
    upper_x_limit = [500 500]; % in ms
    grand_average_flag = 1;
    trial_number = 1;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Assign figure variables

    [title_fontweight,lable_fontsize, lable_fontweight, legend_fontsize, num_of_source_in_figure, column_title_position, show_xlabel] = mainfigure_variables(scenario);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % load model space files
    load(BMS_fullfile{condition_number});
    index = find([BMS.DCM.rfx.bma.Mocc{:}] == winning_model_number(condition_number));                    % finding subjects with optimum model being the winning model


    load(GCM_fullname{condition_number});
    GCM = data.GCM;
    

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % DCM best fitted participant
    number_of_best_DCM(condition_number) = find_best_participant(GCM_fullname{condition_number}, winning_model_number(condition_number), index);
    
    for DCM_number = index
        idx_of_subject_number = strfind(GCM{DCM_number,winning_model_number(condition_number)}, string_to_find) + length(string_to_find);
        actual_subject_numbers(DCM_number) = str2num(GCM{DCM_number,winning_model_number(condition_number)}(idx_of_subject_number: idx_of_subject_number + 1));
        load(GCM{DCM_number,winning_model_number(condition_number)});
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Plot scalp map of the best fitted participant
        if data.included_subject_numbers(DCM_number) == number_of_best_DCM(condition_number)
            figure1(condition_number) = figure('units','normalized','outerposition',[0 0 1 1]);
            whole_min_max = plot_DCM_scalp_map(DCM);
            han=axes(figure1(condition_number),'visible','off'); 
    %        han.Title.Visible='on';
    %        title(han,'Scalp map of the best subject');
            han.YLabel.Visible='off';
            han.XLabel.Visible='on';
            ylh = ylabel(han,[DCM.xY.code{trial_number} ' - Participant No. ' num2str(data.included_subject_numbers(DCM_number)) ],  'FontSize', 24, 'FontWeight','bold');
            ylh.Position(1) = ylh.Position(1) - 0.1; % change vertical position of ylabel
            xlh = xlabel(han,['Time from stimulus onset (ms)'],  'FontSize', lable_fontsize, 'FontWeight', lable_fontweight);
            
            c = colorbar(han,'Position',[0.955 0.168 0.022 0.7]);  % attach colorbar to han
            colormap(c, 'jet')
            minColorLimit = whole_min_max{trial_number}(2,:);
            maxColorLimit = whole_min_max{trial_number}(1,:);
            clim(han,[minColorLimit,maxColorLimit]);
            
            c.FontSize = 12;
            c.Label.String = 'Scaled voltage (a.u.)';
            c.Label.Position = [-0.8 0 0];
            c.Label.FontSize = 18;
            
            

        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Calculate neural activity matrix in the source space (K) for each participant
        [K, ns, nt] = cal_neural_activity(DCM);
        % scale = DCM.xY.scale; 
        % for i = 1 : length(K)
        %     K{i} = K{i} ./ scale; % Scale back to the original values
        % end
        subject(DCM_number).K = K;  % storing neural activity (source space) converted to its actual scale
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % % Integrate neural activity of all optimum subjects in one cell
    phase_name{condition_number} = DCM.xY.code{trial_number};
    % if ~exist('whole_K', 'var')
    %     whole_K = cell(length(subject(index(1)).K), length(index));
    % end
    % for trial_number = 1 : length(subject(index(1)).K)    
    %     for subject_num = index
    %         whole_K{condition_number, subject_num} = subject(subject_num).K{trial_number};
    %     end
    % end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Plot neural population activity
    sources = 1 : ns;
    source_vector = splitvector(sources, num_of_source_in_figure);
    for source_group = 1 : length(source_vector)
        if source_group == length(source_vector) % rem(source_group, num_of_source_in_figure) == 0 || (rem(length(source_vector), num_of_source_in_figure) ~= 0) 
            show_XTicklabel = 1;
        else
            show_XTicklabel = 0;
        end
        % assign tiles variables
        ns = source_vector{source_group};
        columns_in_figure = length(population_number);
        axgrid = [num_of_source_in_figure, columns_in_figure];      % grids of the main figures

        if condition_number == 1
                % Get the screen size
                screenSize = get(0, 'ScreenSize');
                screenWidth = screenSize(3);
                screenHeight = screenSize(4);
                
                % Create a figure with double the screen height
                
                figures(source_group) = figure('Position', [100, 100, screenWidth, 2 * screenHeight]); %figure('units','normalized','outerposition',[0 0 1 2]);
                main_tiled_figures (source_group) = tiledlayout(axgrid(1),1 , "TileSpacing", "compact");
            else
                set(0, 'currentfigure', figures(source_group));
        end 

        if ~exist('integrated_data', 'var')
            integrated_data = struct();
        end
        
        for subject_num = find((data.included_subject_numbers == number_of_best_DCM(condition_number)) == 1)
            grand_average_flag = 0;
            if condition_number == 1
                tcl{source_group} = gobjects(1,axgrid(1));
                ax{source_group} = gobjects(axgrid); 
            end
            [tcl{source_group}, ax{source_group}] = plot_one_population_activity(main_tiled_figures (source_group), tcl{source_group}, ax{source_group}, axgrid, ns, population_number, subject(subject_num).K, DCM, grand_average_flag, upper_x_limit, condition_number, scenario, ...
                show_XTicklabel);
        
            hold on
            grand_average_flag = 1;
            [tcl{source_group}, ax{source_group}] = plot_one_population_activity(main_tiled_figures (source_group), tcl{source_group}, ax{source_group}, axgrid, ns, population_number, whole_K, DCM, grand_average_flag, upper_x_limit, condition_number, scenario, ...
                show_XTicklabel);
                

        end



        %%%% add legend
        if condition_number == condition_vector(end) && source_group == length(source_vector)
            hPlots = flip(findall(gcf,'Type','Line')); % flipped, because the lines our found in reverse order of appearance.
            leg = legend(hPlots([2 4]),'Orientation', 'Vertical','FontSize', legend_fontsize);
            % leg.Layout.Tile = 'best';

            % % Set the legend position to the bottom of the figure
            % set(leg, 'Units', 'normalized');
            % set(leg, 'Position', [0.5, 0.01, 0.0, 0.0], 'Orientation', 'vertical'); % Adjust these values as needed

        end
        %%%% add title to each column
        
        set(0, 'currentfigure', figures(source_group));
        if condition_number == condition_vector(end) && show_xlabel && show_XTicklabel
            xlabel(main_tiled_figures (source_group), 'Time from stimulus onset (ms)','FontSize',lable_fontsize, 'FontWeight', lable_fontweight);
        end

        if condition_number == condition_vector(end) && rem(source_group, num_of_source_in_figure) ~= 0 %source_group == 1
            first_panel_position = cell(1,size(ax{source_group}, 2));
            title_poision = cell(1,size(ax{source_group}, 2));
            for column_number = 1 : size(ax{source_group}, 2)
                first_panel_position{column_number} = get(ax{source_group}(1, column_number), 'Position');
                title_poision{column_number} = first_panel_position{column_number} - column_title_position;
                titleHandles = annotation('textbox','String',population_names{population_number(column_number)}, ...
                    'Position', title_poision{column_number}, ... 
                    'HorizontalAlignment', 'center','VerticalAlignment','bottom',...
                    'LineStyle','none','FitBoxToText','on', ...
                    'FontWeight',title_fontweight, ... % matches title property
                    'FontSize', lable_fontsize);   % matches title property
            end
        end
        
    end
        
    
    %% Saving the plots
    FolderName = fullfile('C:\Users\se16008969\OneDrive - Ulster University\DCM\Confidence\EEG DCM\Plot population Voltages with sustained input', phase_name{condition_number});   % Your destination folder
    if ~isfolder(FolderName)
        mkdir(FolderName);
    end
    if save_flag == 1
    
        FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
        for iFig = 1:length(FigList)
          FigHandle = FigList(iFig);
          FigName   = ['Figure ' num2str(length(FigList) - iFig + 1)];
          savefig(FigHandle, fullfile(FolderName, [FigName, '.fig']));
          exportgraphics(FigHandle,fullfile(FolderName, [FigName, '.png']),'Resolution',300)
        end
    end
    
    population.phase_name = phase_name{condition_number};
    population.number_of_best_DCM = number_of_best_DCM(condition_number);
    population.actual_subject_numbers = actual_subject_numbers;
    population.winning_model_number = winning_model_number(condition_number);
    population.GCM_fullname = GCM_fullname{condition_number};
    population.whole_K = whole_K;
    population.subjects = subject;
    
    save(fullfile(FolderName,'data.mat'),'population');
end
end
% for neural_population_number = population_number
% 
%     figure('units','normalized','outerposition',[0 0 0.5 1]);
%     grand_average_flag = 1;
%     plot_one_population_activity(ns, nt, neural_population_number, population_names, Averaged_K, DCM, grand_average_flag);
% 
% end
% figure    
% for i = 1:ns
%     str   = {};
%     for k = 1:nt        
%         
%         subplot(ceil(ns/2),2,i), hold on
%         for j = [1 3 7]
% 
% 
%                 plot( K{k}(:,i + 7*(j - 1)), ...
%                     'LineWidth',2);
%                 hold on
% 
%             str{end + 1} = sprintf([population_names{j} ' in ' DCM.xY.code{k}]);
%         end
%         title(DCM.Sname{i})
%     end
% 
% end
% xlabel('time (ms)','FontSize',14)
% legend(str)
