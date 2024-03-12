function common_feature_results = extract_significantly_common_features(all_subject_data, performance_bootstrap_analysis_results, significance_level, num_permutations, condition_number)
    % Check if significance_level and num_permutations are provided, if not, set to default values
    if nargin < 3
        significance_level = 0.05; % Default significance level
    end
    if nargin < 4
        num_permutations = 10000; % Default number of permutations
    end

    if nargin < 4
        condition_number = 1; % Default number of permutations
    end
    
    % Determine the number of subjects
    num_subjects = length(all_subject_data);
    
    % Extract the number of conditions and their names
    num_conditions = length(all_subject_data{1}.regression_results);
    condition_names = all_subject_data{1}.condition_names;
    
    % Initialize the common_feature_results structure array
    common_feature_results = struct('ConditionName', [], 'CommonFeatures', [], 'PopulationNames', [], 'SourceNames', []);
    
    % Define a significance threshold for p_values
    p_threshold = 0.05;
        
    % Loop over each condition
    for cond = 1:num_conditions
        % Extract the number of cases, sources, and populations for the current condition
        num_cases = length(performance_bootstrap_analysis_results{cond}.CaseResults);
        [num_sources, num_populations] = size(all_subject_data{1}.regression_results{cond}{1}.ImportantDatapoints);
        
        % Extract population names and source names for the current condition
        population_names = performance_bootstrap_analysis_results{cond}.PopulationNames;
        source_names = performance_bootstrap_analysis_results{cond}.SourceNames;
        
        % Initialize the cell array for common features for each case
        common_features_by_case = cell(1, num_cases);
        
        % Loop over each case
        for case_idx = 1:num_cases
            % Temporary variable to store results in parallel loop
            tmp_common_features = cell(num_sources, num_populations);
            
            % Use parfor for parallelizing the loops over sources and populations
            for src = 1:num_sources
                for pop = 1:num_populations
                    % Check if the source and population are significant based on p_values
                    if performance_bootstrap_analysis_results{cond}.CaseResults{case_idx}.PValues(src, pop) <= p_threshold
                        % Concatenate the lists of important features from all subjects
                        concatenated_features = [];
                        for subj = 1:num_subjects
                            features = all_subject_data{subj}.regression_results{cond}{case_idx}.ImportantDatapoints{src, pop}(1, :);
                            concatenated_features = [concatenated_features, features];
                        end
                        
                        % Count the number of occurrences of each feature
                        [unique_features, counts] = count_unique(concatenated_features);
                        
                        % Perform a permutation test to find the threshold for significance
                        threshold = permutation_test_threshold(counts, significance_level, num_permutations);
                        
                        % Find the features that occur significantly more frequently
                        significantly_common = unique_features(counts >= threshold);
                        
                        % Store the significantly common features in the temporary variable
                        tmp_common_features{src, pop} = significantly_common;
                    end
                end
            end
            
            % Store common features for the current case in a single structure
            behavior = performance_bootstrap_analysis_results{cond}.CaseResults{case_idx}.Behavior;
            caseStruct = struct();
            caseStruct.Behavior = behavior;
            caseStruct.CommonFeatures = tmp_common_features;
            
            common_features_by_case{case_idx} = caseStruct;
        end
        
        % Assign the results to the common_feature_results structure array
        common_feature_results(cond).ConditionName = condition_names{cond};
        common_feature_results(cond).CommonFeatures = common_features_by_case;
        common_feature_results(cond).PopulationNames = population_names;
        common_feature_results(cond).SourceNames = source_names;
    end
end
