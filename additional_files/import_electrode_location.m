for i = 1 : length(electrodeinfo)
    for j = 1 : length(standard105cap385)
        if (strcmpi(electrodeinfo{i,1}, standard105cap385{j,2}))
            for k = 1 : size(standard105cap385,2)
                Channel_Locs{i,k} = standard105cap385{j,k};
            end
        end
    end
end
filename = 'F:\Raw Data\fMRI - EEG\Sabina''s Decision Making\additional_files\final_electrodeinfo.txt';
writecell(Channel_Locs,filename, 'Delimiter', '\t')