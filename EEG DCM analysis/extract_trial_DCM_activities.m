function output = extract_trial_DCM_activities(all_subject_data, significant_population_in_condition, scenario_number, condition_number)
    % Load the scenario variables
    current_scenario_variables = scenario_variables(scenario_number);
    
    % Extract the row of cells corresponding to the scenario_number
    scenario_data = all_subject_data(scenario_number, :);
    
    % Initialize the output cell array
    output = significant_population_in_condition;
    
    % Loop through each structure in significant_population_in_condition
    for i = 1:length(significant_population_in_condition)
        behavior_data = significant_population_in_condition{i};
        behavior = behavior_data.Behavior;
        
        % Initialize the concatenated matrices for each cell in source_activity
        [m, p] = size(behavior_data.ActualSequences);
        concatenated_source_activity = cell(m, p);
        
        % Initialize the 't' field
        t = [];
        
        % Loop through each cell in source_activity
        for row = 1:m
            for col = 1:p
                if ~isempty(behavior_data.ActualSequences{row, col})
                    % Initialize the matrix to be concatenated for the (row, col)-th cell in source_activity
                    concatenated_matrix_low = [];
                    concatenated_matrix_high = [];
                    
                    % Loop through each cell in the row corresponding to the scenario_number
                    for j = 1:length(scenario_data)
                        % Extract the structure corresponding to the condition_number
                        condition_data = scenario_data{j};
                        
                        % Extract the 'neural_population_activity' field for the specific condition_number
                        neural_population_activity = condition_data.neural_population_activity{condition_number};
                        
                        % Extract the 'source_activity' field
                        source_activity = neural_population_activity.source_activity;
                        
                        % Extract the comparing variable and calculate the 25th and 75th percentiles
                        comparing_variable = condition_data.behavioral_data{condition_number}.(current_scenario_variables.comparing_variable_name{1});
                        q1 = prctile(comparing_variable, 25);
                        q3 = prctile(comparing_variable, 75);
                        
                        % Find indices of comparing_variable in the first and last quarters
                        low_indices = comparing_variable <= q1;
                        high_indices = comparing_variable >= q3;
                        
                        % Concatenate the matrices column-wise
                        concatenated_matrix_low = [concatenated_matrix_low, source_activity{row, col}(:, low_indices)];
                        concatenated_matrix_high = [concatenated_matrix_high, source_activity{row, col}(:, high_indices)];
                        
                        % Extract the 't' field
                        if isempty(t)
                            t = neural_population_activity.t;
                        end
                    end
                    
                    % Add the concatenated matrix to the cell array
                    concatenated_source_activity{row, col} = {concatenated_matrix_low, concatenated_matrix_high};
                end
            end
        end
        
        % Add the concatenated_source_activity to the output structure
        output{i}.concatenated_source_activity = concatenated_source_activity;
        output{i}.comparing_trial_names = scenario_variables(scenario_number).comparing_trial_names;
        % Add the 't' field to the output structure
        output{i}.t = t;
    end
end
