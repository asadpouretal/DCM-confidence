function feature_importance = permutation_importance(SVRModel, X, y, n_permutations)
    % Set default values if not provided
    if nargin < 4 || isempty(n_permutations)
        n_permutations = 1000; % For 1000 permutations
    end
    % Initialize the feature_importance vector
    n_features = size(X, 2);
    feature_importance = zeros(1, n_features);

    % Calculate the baseline performance
    baseline_pred = predict(SVRModel, X);
    baseline_perf = corr(baseline_pred, y);

    % Loop over each feature
    for i = 1:n_features
        % Initialize the decrease in performance for the current feature
        delta_perf = 0;

        % Perform n_permutations for the current feature
        for j = 1:n_permutations
            % Create a copy of the data with the current feature permuted
            X_permuted = X;
            X_permuted(:, i) = X_permuted(randperm(size(X, 1)), i);

            % Calculate the performance with the permuted feature
            permuted_pred = predict(SVRModel, X_permuted);
            permuted_perf = corr(permuted_pred, y);

            % Accumulate the decrease in performance
            delta_perf = delta_perf + (baseline_perf - permuted_perf);
        end

        % Average the decrease in performance and store in feature_importance
        feature_importance(i) = delta_perf / n_permutations;
    end
end
