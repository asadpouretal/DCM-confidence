function output = extract_significant_neural_population(input_structure, seq_length, missing_threshold, actual_sequence_threshold)
    common_features = input_structure.CommonFeatures;
    n = length(common_features);
    output = cell(1, n);
    for i = 1:n
        behavior = common_features{i}.Behavior;
        common_features_vectors = common_features{i}.CommonFeatures;
        [m, p] = size(common_features_vectors);
        actual_sequences = cell(m, p);
        complete_sequences = cell(m, p);
        for j = 1:m
            for k = 1:p
                vector = common_features_vectors{j, k};
                [actual_seq, complete_seq] = find_consecutive_sequence(vector, seq_length, missing_threshold, actual_sequence_threshold);
                actual_sequences{j, k} = actual_seq;
                complete_sequences{j, k} = complete_seq;
            end
        end
        output{i} = struct('ConditionName', input_structure.ConditionName, 'Behavior', behavior, 'CommonFeatures', {common_features_vectors}, 'ActualSequences', {actual_sequences}, 'CompleteSequences', {complete_sequences}, 'PopulationNames', {input_structure.PopulationNames},...
            'SourceNames', {input_structure.SourceNames});
    end
end
