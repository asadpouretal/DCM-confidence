function out_neural_population_activity = extract_neural_activity(subject_number, condition_name, parent_DCM_folder)
    % EXTRACT_NEURAL_ACTIVITY Extracts neural population activities for all sources in DCM for a subject.
    % 
    % Usage:
    %     neural_population_activity = extract_neural_activity(subject_number, condition_name, parent_DCM_folder)
    %
    % Inputs:
    %     subject_number       - Numeric identifier for the subject.
    %     condition_name       - Name of the experimental condition.
    %     parent_DCM_folder    - Parent folder containing the DCM data.
    %
    % Outputs:
    %     neural_population_activity - Cell array containing neural population activity.
    
    % Generate subject name and folder
    subject_name = sprintf('sub-%02d', subject_number);
    subject_DCM_folder = ['EEG_data_' subject_name '_run-02'];
    full_subject_folder = fullfile(parent_DCM_folder, condition_name, subject_DCM_folder);

    % Get a list of all .mat files in the specified folder
    mat_files = dir(fullfile(full_subject_folder, '*.mat'));

    % Preallocate a cell array to hold the loaded data
    data_cell = cell(length(mat_files), 1);

    % Loop through each .mat file, load it, and calculate neural population activity
    for i = 1:length(mat_files)
        file_name = fullfile(full_subject_folder, mat_files(i).name);
        load(file_name, 'out_DCM');
        
        for trial = 1:length(out_DCM)
            neural_population_activity{i, trial} = calculate_population_activity(out_DCM{trial}, condition_name);
        end
    end
    out_neural_population_activity = concatenateSourceActivity(neural_population_activity); 
end
