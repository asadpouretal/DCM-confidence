function [GCM,subject_nums, inference_dir] = GCM_extract(main_dir,inference_method, inference_folder_name, model_file_names, dir_name_for_inputs, family_model_names, subjects_to_be_removed, total_subject_nums)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
params = getParameters();
addpath(params.spm_dir) % add spm path to MATLAB path
addpath(params.EEGLAB_dir)  % add EEGLAB path to MATLAB path
spm('defaults','EEG');

num_of_models_for_subs = length(model_file_names);
num_of_scenarios = size(dir_name_for_inputs,1);
%% finding subjects with incomplete DCM estimates
for scenario_num = 1 : num_of_scenarios
    DCM_dir{scenario_num} = fullfile(main_dir, dir_name_for_inputs);
    subject_folder_names{scenario_num} = extract_subfolder(DCM_dir{scenario_num});
end
num_of_subs = extract_sub_num(subject_folder_names);
for i = 1 : length(num_of_subs)
    all_subjects = 1: total_subject_nums;
    subs_to_remove{i}  = setdiff(all_subjects, num_of_subs{i});
end

for scenario_num = 1 : num_of_scenarios
    Removed_subject_numbers = [];
    for sub_num = 1 : length(num_of_subs{scenario_num})
        fileinfo = dir(fullfile(DCM_dir{scenario_num},subject_folder_names{scenario_num}{sub_num}));
        if length(fileinfo) ~= num_of_models_for_subs + 2
            Removed_subject_numbers = [Removed_subject_numbers num_of_subs{scenario_num}(sub_num)];
            removed_subject_num{scenario_num} = Removed_subject_numbers;
        end
    end
end

    if exist('removed_subject_num','var')
        Removed_subject_numbers = unique([cell2mat(removed_subject_num) cell2mat(subs_to_remove) subjects_to_be_removed]);
    else
        Removed_subject_numbers = [subjects_to_be_removed];
    end


%% Creating inference folder
inference_dir = fullfile(main_dir,inference_folder_name,inference_method);

if isfolder(inference_dir)
    rmdir(inference_dir, 's');    
end
mkdir(inference_dir);
%% Creating cell array of DCMs for each subject

subject_nums = unique(cell2mat(num_of_subs));
if ~isempty(Removed_subject_numbers)
    subject_nums = setdiff(subject_nums,Removed_subject_numbers)
end


Subject_Number = 1;
for subject_num = subject_nums
    model_number = 1;
    for scenario_num = 1 : num_of_scenarios
        family_model_nums{scenario_num} = [];
        for model_file_num = 1 : length(model_file_names)
            dcmmat{model_number} = fullfile(DCM_dir{scenario_num}, subject_folder_names{scenario_num}{find((cell2mat(num_of_subs) == subject_num) == 1)}, model_file_names{model_file_num});
            GCM{Subject_Number, model_number} = dcmmat{model_number};
            family_model_nums{scenario_num} = [family_model_nums{scenario_num} model_number];
            model_number = model_number + 1;
        end
    end
    dcm{Subject_Number} = dcmmat';
    Subject_Number = Subject_Number + 1;
end



matlabbatch{1}.spm.dcm.bms.inference.dir = {inference_dir};
for Subject_Number = 1 : length(dcm)
    matlabbatch{1}.spm.dcm.bms.inference.sess_dcm{Subject_Number}.dcmmat =  dcm{Subject_Number};
end

matlabbatch{1}.spm.dcm.bms.inference.model_sp = {''};
matlabbatch{1}.spm.dcm.bms.inference.load_f = {''};
matlabbatch{1}.spm.dcm.bms.inference.method = inference_method;
if length(family_model_nums) < 2
    matlabbatch{1}.spm.dcm.bms.inference.family_level.family_file = {''};
else
    for family_num = 1 : length(family_model_nums)
        matlabbatch{1}.spm.dcm.bms.inference.family_level.family(family_num).family_name = family_model_names{family_num};
        matlabbatch{1}.spm.dcm.bms.inference.family_level.family(family_num).family_models = family_model_nums{family_num}';
    end
end

matlabbatch{1}.spm.dcm.bms.inference.bma.bma_yes.bma_famwin = 'famwin';
matlabbatch{1}.spm.dcm.bms.inference.verify_id = 1;

spm_jobman('run',matlabbatch);
end