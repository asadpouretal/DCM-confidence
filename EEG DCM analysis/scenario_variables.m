function [out_variables] = scenario_variables(scenario_number)

params = getParameters();

%scenario_variables returns the conditions and base directory
%   Detailed explanation goes here
    
    % High and low confidence (scenario 1)
    scenario(1).condition_name      = params.high_low_condition_name;
    scenario(1).Pbase               = fullfile(params.high_low_result_path, 'SPM Analyses');
    scenario(1).trial_DCM_folder   = 'Winning DCM - trial by trial';
    scenario(1).analysis_parent_folder = params.trial_by_trial_analysis_folder;
    scenario(1).main_result_folder  = params.high_low_result_folder_name;
    scenario(1).behavior_cases = {'Reaction Time', 'Confidence Rating'};
    scenario(1).cluster_centroids = {[5 7 11]};
    scenario(1).subjects_to_be_removed = params.subjects_to_be_removed;
    scenario(1).comparing_variable_name = {'reaction_time'};
    scenario(1).comparing_trial_names = {'Fast RTs', 'Slow RTs'};
    scenario(1).comparing_trial_values = params.cluster_centroids;

    % fast and slow RTs (scenario 2)
    scenario(2).condition_name  = params.fast_slow_condition_name;
    scenario(2).Pbase           = fullfile(params.fast_slow_result_path, 'SPM Analyses');
    scenario(2).trial_DCM_folder   = 'Winning DCM - trial by trial';
    scenario(2).analysis_parent_folder = params.trial_by_trial_analysis_folder;
    scenario(2).main_result_folder  = params.fast_slow_result_folder_name ;
    scenario(2).behavior_cases = {'Reaction Time', 'Confidence Rating'};
    scenario(2).cluster_centroids = params.cluster_centroids;
    scenario(2).subjects_to_be_removed = params.subjects_to_be_removed;
    scenario(2).comparing_variable_name = {'confidence_rating'};
    scenario(2).comparing_trial_names = {'Low Conf.', 'High Conf.'};
    scenario(2).comparing_trial_values = {[5 7 11]};

    % rating and stimulation phase (scenario 3)
    scenario(3).condition_name  = {'Rating', 'Stimulation'};
    scenario(3).Pbase           = fullfile(params.main_dir, 'Results of Rating Phase', 'SPM Analyses');
    scenario(3).trial_DCM_folder   = 'Winning DCM - trial by trial';
    scenario(3).analysis_parent_folder = params.trial_by_trial_analysis_folder;
    scenario(3).main_result_folder  = 'Results of Rating Phase';
    scenario(3).behavior_cases = {'Reaction Time', 'Confidence Rating'};
    scenario(3).cluster_centroids   = [];
    scenario(3).subjects_to_be_removed = params.subjects_to_be_removed;

    if scenario_number <= length(scenario) 
        out_variables = scenario(scenario_number);
    else
        out_variables = [];
    end

end