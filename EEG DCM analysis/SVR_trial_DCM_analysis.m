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
    addpath(spm12_folder, eeglab_folder);
    
    spm('defaults','EEG');
    disp('MATLAB is running on Linux or Mac.');
    main_raw_data_folder = params.main_dir;
    main_result_folder = params.main_dir;
    linux_flag = 1;
else
    disp('Unknown operating system.');
end


trial_by_trial_analysis_folder = params.trial_by_trial_analysis_folder;
performance_threshold = params.performance_threshold;    % Set this to your desired threshold between 0 and 1
time_window = params.correlation_time_window;  % Time window to analyse performance from the 
% onset of each trial in milliseconds
num_subjects = params.total_subjects ;
significance_level = params.significance_level; % For example, 0.001 for a significance level of 0.1%.
number_of_important_feature_permutation = params.number_of_important_feature_permutation;   % try 1250 for defualt
num_permutations = params.num_permutations; % try 10000 for default
num_top_features = params.num_top_features;      % number of top data points with significant correlation

% Initialize a cell array to temporarily store the extracted data for each scenario and subject
temp_subject_data = cell(2, num_subjects);

% Create a list of all subject numbers
all_subjects = 1:num_subjects;


% Get the list of subjects to be removed for the current scenario
subjects_to_be_removed = scenario_variables(1).subjects_to_be_removed;
% Remove subjects from the list
subject_indices = setdiff(all_subjects, subjects_to_be_removed);

num_of_workers = params.numWorkers;

% Check if there's an active parallel pool
currentPool = gcp('nocreate');

% If a pool exists, delete it
if ~isempty(currentPool)
    delete(currentPool);
    disp('Parallel pool deleted.');
else
    disp('No active parallel pool found.');
end

parpool(num_of_workers);


for scenario_idx = 1:length(params.scenarios)
    scenario_number = scenario_idx; % Assuming the two scenarios are numbered 1 and 2

    % Create an empty cell array to store the data from the parfor loop
    subject_data_array = cell(1, length(subject_indices));

    % Use parfor for parallel execution with the modified subject_indices
    parfor idx = 1:length(subject_indices)
        subject_number = subject_indices(idx);
        % Extract data for the current subject and scenario
        data = perform_neural_behavioral_analysis(main_raw_data_folder, main_result_folder, scenario_number, subject_number, time_window, num_top_features, number_of_important_feature_permutation);
        
        % Store the extracted data in the separate array
        subject_data_array{idx} = data;
    end
    
    % Transfer the data from subject_data_array to temp_subject_data
    for idx = 1:length(subject_indices)
        subject_number = subject_indices(idx);
        temp_subject_data{scenario_idx, subject_number} = subject_data_array{idx};
    end


    % Remove empty cells from the cell array
        % Find non-empty columns
        non_empty_columns = ~all(cellfun('isempty', temp_subject_data), 1);
        
        % Index into the original array to get only the non-empty columns
        all_subject_data = temp_subject_data(:, non_empty_columns);
    
    % Define the path for the 'trial_by_trial_analysis' folder
    scenario_result_folder =  scenario_variables(scenario_number).main_result_folder;
    save_folder = fullfile(main_result_folder, trial_by_trial_analysis_folder, scenario_result_folder);
    
    % Check if the folder exists; if not, create it
    if ~exist(save_folder, 'dir')
        mkdir(save_folder);
    end
    
    % Save all_subject_data in the specified folder
    save_path = fullfile(save_folder, 'all_subject_data.mat');
    save(save_path, 'all_subject_data','-v7.3');
    
    performance_bootstrap_analysis_results{1, scenario_number} = analyse_regression_results_bootstrap(all_subject_data(scenario_number, :), performance_threshold, significance_level, num_permutations);
    
    % extract significant common data points
    common_feature_results{1, scenario_number} = extract_significantly_common_features(all_subject_data(scenario_number, :), performance_bootstrap_analysis_results{1, scenario_number}, significance_level, num_permutations);
    save(save_path, 'all_subject_data', 'performance_bootstrap_analysis_results', 'common_feature_results','-v7.3');
end

% Save all_subject_data in the specified folder


% Shut down the parallel pool
delete(gcp);

% Reset the path to the original state
path(originalPath);

% Optionally, save the path
savepath;
