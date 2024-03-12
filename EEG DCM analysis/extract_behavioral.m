function [behavioral_data] = extract_behavioral(subject_number, condition_name, main_data_folder)
    % Initialize output structure
    behavioral_data = struct();
    
    % Define the Event Path
    Event_Path = fullfile(main_data_folder, 'EEG_events_EEGfMRI');
    
    % Generate subject name
    subject_name = sprintf('sub-%02d', subject_number);
    
    % Generate the search pattern
    searchPattern = fullfile(Event_Path, ['*' subject_name '*']);
    
    % Find files matching the search pattern
    matchingFiles = dir(searchPattern);
    
    % Initialize variables to hold data across files
    reaction_time = cell(1, length(matchingFiles));
    confidence_rating = cell(1, length(matchingFiles));
    accuracy_values = cell(1, length(matchingFiles));
    
    % Load and process each file
    for i = 1:length(matchingFiles)
        fprintf('Loading file: %s\n', matchingFiles(i).name);
        
        % Generate full file path
        filePath = fullfile(Event_Path, matchingFiles(i).name);
        
        % Load variables from the file
        load(filePath, 'RT', 'confidence', 'accuracy');
        
        % Get trial indices based on condition
        trial_index = getTrialIndices(condition_name, subject_number, RT, confidence);
        
        % Extract and store data for this file
        reaction_time{i} = RT(trial_index);
        confidence_rating{i} = confidence(trial_index);
        accuracy_values{i} = accuracy(trial_index);
    end
    
    % Concatenate data across files
    behavioral_data.reaction_time = horzcat(reaction_time{:});
    behavioral_data.confidence_rating = horzcat(confidence_rating{:});
    behavioral_data.accuracy = horzcat(accuracy_values{:});
    behavioral_data.condition_name = condition_name;
end

function [trial_index] = getTrialIndices(condition_name, subject_number, RT, confidence)
    % Helper function to get trial indices based on condition

    condition_name = lower(condition_name); % Convert condition_name to lowercase for consistent checking

    if contains(condition_name, 'slow') || contains(condition_name, 'fast')
        scenario_number = 2;
        scenario = scenario_variables(scenario_number);
        thresholds = scenario.cluster_centroids;
        if contains(condition_name, 'slow')
            trial_index = RT > thresholds{subject_number}(2);
        else
            trial_index = RT < thresholds{subject_number}(1);
        end

    elseif contains(condition_name, 'low') || contains(condition_name, 'high')
        scenario_number = 1;
        scenario = scenario_variables(scenario_number);
        thresholds = scenario.cluster_centroids{1};
        if contains(condition_name, 'low')
            trial_index = confidence < thresholds(1);
        else
            trial_index = confidence > (thresholds(2) - 1) & confidence < thresholds(3);
        end

    else
        error('Invalid condition name.');
    end
end