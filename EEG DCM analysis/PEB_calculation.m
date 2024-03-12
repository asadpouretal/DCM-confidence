function PEB_calculation(result_dir, condition_names, winning_model_number)

restoredefaultpath;
params = getParameters();
addpath(params.spm_dir) % add spm path to MATLAB path
addpath(params.EEGLAB_dir)  % add EEGLAB path to MATLAB path
spm; close;
spm('defaults','EEG');

for condition_number = 1: length(condition_names)
    GCM_fullname{condition_number} = fullfile(result_dir, ['BMS_first_level_analysis_' condition_names{condition_number} '.mat']);
    inference_folder_name = [params.inference_folder_pattern filesep condition_names{condition_number}];
    inference_dir = fullfile(result_dir,inference_folder_name);
    if ~isfolder(inference_dir)
        mkdir(inference_dir);
    end
    
    load(GCM_fullname{condition_number});
    GCM = data.GCM;
    GCM_filename = fullfile(inference_dir,'GCM.mat');
    save(GCM_filename,'GCM');
    %% Create PEB
    matlabbatch = [];
    PEB_name = condition_names{condition_number};
    matlabbatch{1}.spm.dcm.peb.specify.name = PEB_name;
    matlabbatch{1}.spm.dcm.peb.specify.model_space_mat = {GCM_filename};
    matlabbatch{1}.spm.dcm.peb.specify.dcm.index = winning_model_number(condition_number);
    % matlabbatch{1}.spm.dcm.peb.specify.dcm.all = 'All DCMs';
    matlabbatch{1}.spm.dcm.peb.specify.cov.none = struct([]);
    matlabbatch{1}.spm.dcm.peb.specify.fields.default = {
                                                         'A'
                                                         }';
    matlabbatch{1}.spm.dcm.peb.specify.priors_between.components = 'All';
    matlabbatch{1}.spm.dcm.peb.specify.priors_between.ratio = 16;
    matlabbatch{1}.spm.dcm.peb.specify.priors_between.expectation = 0;
    matlabbatch{1}.spm.dcm.peb.specify.priors_between.var = 0.0625;
    matlabbatch{1}.spm.dcm.peb.specify.priors_glm.group_ratio = 1;
    matlabbatch{1}.spm.dcm.peb.specify.estimation.maxit = 64;
    matlabbatch{1}.spm.dcm.peb.specify.show_review = 1;
    spm_jobman('run',matlabbatch);
    disp(['PEB connections for ' PEB_name]);
    pause
end