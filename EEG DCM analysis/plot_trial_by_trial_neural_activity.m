clear; close all;

params = getParameters();
% Get the file separator
separator = filesep;

% Save the original path
originalPath = path;

% Check the operating system based on the file separator
if strcmp(separator, '\')
    spm12_folder = params.spm_dir;
    eeglab_folder = params.EEGLAB_dir;  
    addpath(spm12_folder, eeglab_folder);
    
    spm('defaults','EEG');
    disp('MATLAB is running on Windows.');
    main_raw_data_folder = params.main_dir;
    main_result_folder = params.main_dir;
    linux_flag = 0;
elseif strcmp(separator, '/')
    spm12_folder = params.spm_dir;
    eeglab_folder = params.EEGLAB_dir;
    jobStorageLocation = fullfile(params.main_dir, 'ParallelJobStorage'); % Replace with your actual job storage location
    
    addpath(spm12_folder, eeglab_folder);
    
    spm('defaults','EEG');
    disp('MATLAB is running on Linux or Mac.');
    main_raw_data_folder = params.main_dir;
    main_result_folder = params.main_dir;
    linux_flag = 1;
else
    disp('Unknown operating system.');
end

time_window = params.correlation_time_window;  % Time window to analyse performance from the  
% onset of each trial in milliseconds
sequence_minimum_length = params.sequence_minimum_length;
sequence_missing_point_threshold = params.sequence_missing_point_threshold;
actual_sequence_point_threshold = params.actual_sequence_point_threshold;
whole_common_features = cell(1,2);
for scenario_number = 1: 2
    condition_names = scenario_variables(scenario_number).condition_name;
    behavior_cases = scenario_variables(scenario_number).behavior_cases;
    for condition_number = 1 : length(condition_names)
        % Define the path for the 'trial_by_trial_analysis' folder
        scenario_result_folder =  scenario_variables(scenario_number).main_result_folder;
        trial_by_trial_analysis_folder = scenario_variables(scenario_number).analysis_parent_folder;
        save_folder = fullfile(main_result_folder, trial_by_trial_analysis_folder, scenario_result_folder);
        
        % Save all_subject_data in the specified folder
        save_path = fullfile(save_folder, 'all_subject_data.mat');
        
        % Check if the folder exists; if not, create it
        if ~exist(save_path, 'file')
            error('No file found for futher analysis!');
        end
        
        load(save_path, 'all_subject_data', 'common_feature_results', 'performance_bootstrap_analysis_results');
        whole_common_features{1, scenario_number}(condition_number) = common_feature_results{1, scenario_number}(condition_number);
        common_features_in_condition = common_feature_results{1, scenario_number}(condition_number);
        significant_population_in_condition = extract_significant_neural_population(common_features_in_condition, sequence_minimum_length, sequence_missing_point_threshold, actual_sequence_point_threshold);
        significant_population_in_condition = extract_trial_DCM_activities(all_subject_data, significant_population_in_condition, scenario_number, condition_number);
        close all;
        plot_average_significant_trial_DCM_activity(significant_population_in_condition, time_window, scenario_number);
        plotAllNeuralCorrelations(significant_population_in_condition);
        disp('Press any key to continue...')
        pause;
    end
end

% Plot your figures here
% Call the function to create a tiled layout with a global legend
% plot_tiled_layout('Arial');