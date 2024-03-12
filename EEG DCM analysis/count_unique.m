function [unique_elements, counts] = count_unique(array)
    % Remove NaN values from the array
    array = array(~isnan(array));
    
    % Find the unique elements in the array
    unique_elements = unique(array);
    
    % Check if unique_elements is empty
    if isempty(unique_elements)
        counts = [];
        return;
    end
    
    % Calculate the minimum difference between adjacent unique elements
    min_diff = min(diff(unique_elements));
    
    % Ensure that unique_elements is a column vector
    unique_elements = unique_elements(:);
    
    % Construct bin edges with uniform width
    bin_edges = [unique_elements; unique_elements(end) + min_diff];
    
    % Use histcounts to count the occurrences of each unique element
    counts = histcounts(array, bin_edges);
end
