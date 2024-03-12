function analysis_results = analyse_regression_results_bootstrap(all_subject_data, performance_threshold, alpha, nBoot, condition_number)
    % Set default values if not provided
    if nargin < 3 || isempty(alpha)
        alpha = 0.05; % For 95% confidence interval
    end
    if nargin < 4 || isempty(nBoot)
        nBoot = 10000;
    end

    if nargin < 5 || isempty(condition_number)
        condition_number = 1;
    end

    % Number of subjects
    num_subjects = length(all_subject_data);

    % Extract the size of the performance matrix from the first subject and first condition
    num_conditions = length(all_subject_data{1}.regression_results);
    [num_sources, num_populations] = size(all_subject_data{1}.regression_results{condition_number}{1}.Performance);
    
    
    % Extract population names and source names from the first subject
    population_names = all_subject_data{1}.neural_population_activity{condition_number}.population_name;
    source_names = all_subject_data{1}.neural_population_activity{condition_number}.sources_name;

    % Initialize structures to store analysis results
    analysis_results = cell(1, num_conditions);
    
    % Loop over each condition
    for cond_idx = 1:num_conditions
        num_cases = length(all_subject_data{1}.regression_results{cond_idx});
        case_results = cell(1, num_cases);
        
        for case_idx = 1:num_cases
            p_values = nan(num_sources, num_populations);
            stats = cell(num_sources, num_populations);

            % Loop over each source and each population
            for src_idx = 1:num_sources
                for pop_idx = 1:num_populations
                    % Extract and stack performance values for the current matrix element across all subjects for the current condition and case
                    performance_values_cell = cellfun(@(x) x.regression_results{cond_idx}{case_idx}.Performance(src_idx, pop_idx), all_subject_data, 'UniformOutput', false);
                    performance_values = cell2mat(performance_values_cell);

                    % Bootstrap the mean
                    boot_means = bootstrp(nBoot, @mean, performance_values);
                    CI = prctile(boot_means, [100*alpha/2, 100*(1-alpha/2)]); % Confidence interval
                    
                    % Check if lower bound of CI is above performance_threshold
                    if CI(1) > performance_threshold
                        p = alpha;
                        p_values(src_idx, pop_idx) = p;
                        stats{src_idx, pop_idx} = CI;
                    end
                end
            end
            
            % Store the results for the current case in a single structure
            behavior = all_subject_data{1}.regression_results{cond_idx}{case_idx}.Behavior;

            % Create a single structure and assign the results
            caseStruct = struct();
            caseStruct.Behavior = behavior;
            caseStruct.PValues = p_values;
            caseStruct.Stats = stats;
            
            case_results{case_idx} = caseStruct;
        end
        
        % Create a single structure for the current condition and assign the results
        conditionStruct = struct();
        conditionStruct.Condition = cond_idx;
        conditionStruct.CaseResults = case_results;
        conditionStruct.PopulationNames = population_names;
        conditionStruct.SourceNames = source_names;
        
        % Store the single structure in the cell array
        analysis_results{cond_idx} = conditionStruct;
    end
end
