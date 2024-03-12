function [splitcell] = splitvector(vector,split_length)
%UNTITLED4 split a vector into cells with split_length
%   Detailed explanation goes here
vector_length = length(vector);
numSplits = ceil(vector_length/split_length);
splitcell = cell(numSplits, 1);
for i = 1 : numSplits
    if (i * split_length) <= vector_length
        splitcell{i} = vector((i - 1) * split_length + 1 : i * split_length);
    else
        splitcell{i} = vector((i - 1) * split_length + 1 : end);
    end
end

end