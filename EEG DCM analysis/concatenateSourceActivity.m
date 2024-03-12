function out_neural_population_activity = concatenateSourceActivity(neural_population_activity)
    % Concatenate vectors from the same index of source_activity across all structures

    % Determine the number of structures and the dimensions of source_activity
    num_structures = length(neural_population_activity);
    num_rows = size(neural_population_activity{1}.source_activity, 1);
    num_cols = size(neural_population_activity{1}.source_activity, 2);

    % Initialize a cell array to hold the concatenated matrices
    concatenated_matrices = cell(num_rows, num_cols);

    % Iterate over each row and column index in source_activity
    for i = 1:num_rows
        for j = 1:num_cols
            % Initialize a matrix to hold concatenated vectors for the current index
            vector_length = length(neural_population_activity{1}.source_activity{i, j});
            matrix_form = zeros(vector_length, num_structures);
            
            % Iterate over each structure and extract the vector for the current index
            for k = 1:num_structures
                matrix_form(:, k) = neural_population_activity{k}.source_activity{i, j};
            end
            
            % Store the concatenated matrix in the cell array
            concatenated_matrices{i, j} = matrix_form;
        end
    end

    % Create the out_neural_population_activity structure
    out_neural_population_activity = neural_population_activity{1}; % Copy fields from the first structure
    out_neural_population_activity.source_activity = concatenated_matrices; % Update the source_activity field
end
