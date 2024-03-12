function threshold = permutation_test_threshold(counts, significance_level, num_permutations)
    % Check if num_permutations is provided, if not, set to default value
    if nargin < 3
        num_permutations = 10000; % Default number of permutations
    end
    
    % Initialize array to store the maximum count from each permutation
    max_counts = zeros(1, num_permutations);
    
    % Perform permutations
    for i = 1:num_permutations
        permuted_counts = counts(randperm(length(counts)));
        max_counts(i) = max(permuted_counts);
    end
    
    % Sort the max counts from the permutations in ascending order
    sorted_max_counts = sort(max_counts);
    
    % Find the threshold for significance
    threshold_idx = ceil((1 - significance_level) * num_permutations);
    threshold = sorted_max_counts(threshold_idx);
end
