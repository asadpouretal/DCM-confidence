function [actual_sequences, complete_sequences] = find_consecutive_sequence(vector, seq_length, missing_threshold, actual_sequence_threshold)
    vector = vector(:)';  % Make sure the vector is a row vector
    vector = sort(vector);  % Sort the vector
    
    n = length(vector);
    temp_complete_sequences = {};  % Use a cell array
    temp_actual_sequences = {};  % Use a cell array if needed
    current_sequence = [];
    missing_points = 0;
    for i = 1:n
        if isempty(current_sequence)
            current_sequence = vector(i);
        elseif vector(i) - current_sequence(end) == 1
            current_sequence = [current_sequence, vector(i)];
        elseif vector(i) - current_sequence(end) <= missing_threshold + 1
            missing_points = missing_points + (vector(i) - current_sequence(end) - 1);
            current_sequence = [current_sequence, (current_sequence(end)+1):vector(i)];
        else
            if length(current_sequence) >= seq_length && missing_points <= missing_threshold
                temp_complete_sequences{end+1} = current_sequence;  % Append to cell array
            end
            current_sequence = vector(i);
            missing_points = 0;
        end
    end
    if length(current_sequence) >= seq_length && missing_points <= missing_threshold
        temp_complete_sequences{end+1} = current_sequence;  % Append to cell array
    end
    
    complete_sequences = {};
    actual_sequences = {};
    for i = 1:length(temp_complete_sequences)  % Iterate through cell array
        sequence = temp_complete_sequences{i};  % Access cell content
        first_num = sequence(1);
        last_num = sequence(end);
        first_index = find(vector == first_num, 1, 'first');
        last_index = find(vector == last_num, 1, 'last');
        actual_sequence = vector(first_index:last_index);
        if length(actual_sequence) >= actual_sequence_threshold
            actual_sequences{end+1} = actual_sequence;  % Append to cell array
            complete_sequences{end+1} = sequence;  % Append to cell array
        end
    end
    
    % If you need to return numeric arrays instead of cell arrays, you'll have to
    % convert these cell arrays back to a suitable numeric matrix or handle them
    % as cell arrays in the calling function.
end
