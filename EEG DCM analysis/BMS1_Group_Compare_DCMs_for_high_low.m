clear; close all;
restoredefaultpath;
params = getParameters();
addpath(params.spm_dir) % add spm path to MATLAB path
addpath(params.EEGLAB_dir)  % add EEGLAB path to MATLAB path
spm; close;

reduced_flag = 0;
condition_names = params.high_low_condition_name;
within_model_names = {{''},{''}};
Model_numbers = params.DCM_model_num;    % number of models in the model space for each condition
subjects_to_be_removed = {params.subjects_to_be_removed, params.subjects_to_be_removed}; % participants withour significant correlation between subjective confidence rating and reaction time
total_subject_nums = params.total_subjects;
for condition_num = 1 : length(condition_names)
    close all
    disp(['Analysing ' condition_names{condition_num}])
    main_DCM_dir = fullfile(params.high_low_result_path, 'SPM Analyses', params.DCM_folder_name);
    inference_method = params.inference_method;
    
    dir_name_for_inputs = condition_names{condition_num}; % DCM Models', 'DCM Models modified input',
    inference_folder_name = [params.inference_folder_pattern filesep condition_names{condition_num}];
    family_model_names = { ['DCM models with sustained input from ' num2str(params.onset_of_DCM_input) ' ms']}; % 'DCM models with Gaussian bump input from 200 ms', 'DCM models with sustained input from 200 ms',
    
    
    % model_file_name_num = 1;
    model_file_names = [];
    for model_number = 1 : Model_numbers(condition_num)
        for within_model = 1 : length(within_model_names{condition_num})
            model_file_names{within_model, model_number} = ['DCM_CMC_M' num2str(model_number) within_model_names{condition_num}{within_model} '.mat'];
        end
    end
    model_file_names = model_file_names(:);
    if reduced_flag
        model_file_names{end + 1} = 'DCM_CMC_reduced.mat';
    end
    BMS_first_level_analysis = [];
    disp(['Performing Bayesian Model Selection for ' condition_names{condition_num}])
    [GCM,subject_nums, inference_dir] = GCM_extract(main_DCM_dir,inference_method, inference_folder_name, model_file_names, dir_name_for_inputs, family_model_names, subjects_to_be_removed{condition_num}, total_subject_nums);
    BMS_first_level_analysis.GCM = GCM;
    BMS_first_level_analysis.included_subject_numbers = subject_nums;
    BMS_first_level_analysis.inference_dir = inference_dir;
    savetofile(BMS_first_level_analysis,[main_DCM_dir filesep 'BMS_first_level_analysis_' condition_names{condition_num} '.mat']);
    save(fullfile(main_DCM_dir, inference_folder_name,'GCM.mat'),'GCM');
    disp(['Condition: ' condition_names{condition_num}]);
    pause
end
