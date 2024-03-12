function subject = perform_neural_behavioral_analysis(main_raw_data_folder, main_result_folder, scenario_number, subject_number, time_window, num_top_features, number_of_important_feature_permutation)
    % Extract condition variables based on scenario number
    condition_variables = scenario_variables(scenario_number);
    condition_names = condition_variables.condition_name;
    condition_numbers = length(condition_names);
    trial_DCM_folder = condition_variables.trial_DCM_folder;
    result_subfolder_name = condition_variables.main_result_folder;
    full_DCM_folder = fullfile(main_result_folder, result_subfolder_name, 'SPM Analyses', trial_DCM_folder);

    % Initialize structures
    behavioral_data = cell(1, condition_numbers);
    neural_population_activity = cell(1, condition_numbers);
    regression_results = cell(1, condition_numbers);

    % Extract behavioral data and neural population activity
    for condition = 1: condition_numbers % 1 : condition_numbers
        condition_name = condition_names{condition};
        behavioral_data{condition} = extract_behavioral(subject_number, condition_name, main_raw_data_folder); % behavioral_data{condition} = extract_behavioral(subject_number, condition_name, main_raw_data_folder);
        neural_population_activity{condition} = extract_neural_activity(subject_number, condition_name, full_DCM_folder); % neural_population_activity{condition} = extract_neural_activity(subject_number, condition_name, full_DCM_folder);
        regression_results{condition} = regress_neural_activity_to_behavior(neural_population_activity{condition}, behavioral_data{condition}, time_window, num_top_features, number_of_important_feature_permutation);
    end

    % Construct the output structure
    subject.scenario = scenario_number;
    subject.subject_number = subject_number;
    subject.behavioral_data = behavioral_data;
    subject.condition_names = condition_names;
    subject.neural_population_activity = neural_population_activity;
    subject.regression_results = regression_results;
    subject.time_window = time_window;
end
