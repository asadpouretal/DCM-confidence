function [subjects_in_scenario] = extract_sub_num(subject_folder_names)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
folder_fixed_name = 'EEG_data_sub-';
for cell_num = 1 : length(subject_folder_names)
    subject_nums = [];
    for folders = 1 : length(subject_folder_names{cell_num})
        indx = strfind(subject_folder_names{cell_num}{folders}, folder_fixed_name);
        number_of_subject = str2num(subject_folder_names{cell_num}{folders}(indx + length(folder_fixed_name): indx + length(folder_fixed_name) + 1));
        subject_nums = [subject_nums number_of_subject];
    end
    subjects_in_scenario{cell_num} =  subject_nums;
end

end