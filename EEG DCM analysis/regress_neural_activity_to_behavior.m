function results = regress_neural_activity_to_behavior(neural_population_activity, behavioral_data, time_window, num_top_features, n_permutations)

    % Set default values if not provided
    if nargin < 5 || isempty(n_permutations)
        n_permutations = 1000; % For 1000 permutations
    end

    % Extract source_activity, reaction_time, confidence_rating, and time data
    source_activity = neural_population_activity.source_activity;
    reaction_time = behavioral_data.reaction_time;
    confidence_rating = behavioral_data.confidence_rating;
    time_data = neural_population_activity.t;
    
    % Find indices corresponding to the time window
    [~, start_idx] = min(abs(time_data - time_window(1)));
    [~, end_idx] = min(abs(time_data - time_window(2)));
    
    % Initialize the performance matrix and other output variables
    [num_sources, num_populations] = size(source_activity);
    behaviors = {'Reaction Time', 'Confidence Rating'};
    n_behaviors = length(behaviors);
    
    results = cell(1, n_behaviors);
    
    
    % Perturbation amount for determining feature direction
    perturbation = 0.01;
    
    % Loop over behaviors: RT and Confidence Rating
    for beh_idx = 1:n_behaviors
        % Select the behavior data
        if beh_idx == 1
            behavior_data = reaction_time;
        else
            behavior_data = confidence_rating;
        end
        
        performance = nan(num_sources, num_populations);
        important_datapoints = cell(num_sources, num_populations);
        SVRModels = cell(num_sources, num_populations);
        
        % Loop over each source and each population
        for src_idx = 1:num_sources
            for pop_idx = 1:num_populations
                % Extract the current neural activity matrix and select the desired time window
                curr_activity = source_activity{src_idx, pop_idx}(start_idx:end_idx, :);
                
                % Transpose the current activity matrix to have trials as rows
                curr_activity = curr_activity';
                
                % Check if the number of rows matches the length of behavior_data
                if size(curr_activity, 1) ~= length(behavior_data)
                    error('Mismatch between the number of trials in neural activity and the length of behavior data.');
                end
                
                % Train the SVR model with a gaussian (RBF) kernel
                SVRModel = fitrsvm(curr_activity, behavior_data, 'KernelFunction', 'gaussian');
                
                % Store the SVRModel
                SVRModels{src_idx, pop_idx} = SVRModel;
                
                % Predict the behavior data using the trained SVR model
                predicted_behavior = predict(SVRModel, curr_activity);
                
                % Compute the correlation between predicted and actual behavior data
                corr_coeff = corr(predicted_behavior, behavior_data');
                
                % Store the performance in the matrix
                performance(src_idx, pop_idx) = corr_coeff;
                
                % Compute Permutation Importance for the features in the SVR model
                feature_importance = permutation_importance(SVRModel, curr_activity, behavior_data', n_permutations);
                
                % Sort feature importances in descending order and select the indices of the top features
                [~, sorted_idx] = sort(feature_importance, 'descend');
                top_features_idx = sorted_idx(1:min(num_top_features, end));
                
                % Determine the direction of influence of each important feature
                directions = zeros(1, length(top_features_idx));
                for i = 1:length(top_features_idx)
                    idx = top_features_idx(i);
                    perturbed_activity = curr_activity;
                    perturbed_activity(:, idx) = perturbed_activity(:, idx) + perturbation;
                    perturbed_behavior = predict(SVRModel, perturbed_activity);
                    directions(i) = sign(mean(perturbed_behavior) - mean(predicted_behavior));
                end
                
                % Combine the indices of important features and their directions and store in important_datapoints
                important_datapoints{src_idx, pop_idx} = [top_features_idx .* directions; directions];
            end
        end
        
        % Create a single structure for the current behavior
        resultStruct = struct();
        resultStruct.Behavior = behaviors{beh_idx};
        resultStruct.Performance = performance;
        resultStruct.ImportantDatapoints = important_datapoints;
        resultStruct.SVRModels = SVRModels;
        
        % Store the single structure in the cell array
        results{beh_idx} = resultStruct;
    end
end
