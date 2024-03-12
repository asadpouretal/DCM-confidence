clearvars; fclose('all');
%% Running parallel computing

%%

params = getParameters();
addpath(params.spm_dir) % add spm12 dir here
spm('defaults','fMRI');

main_dir = params.main_dir; % Specify your main directory
data_main_dir = params.data_main_dir_pattern; %Specify subjects data directory pattern

% spm12_folder = 'C:\Toolbox\spm12';
matlabbatch = [];
total_subjects = params.total_subjects;
total_runs = 2;
num_of_volumes = params.num_of_volumes;
load(fullfile(main_dir, 'extracted_file_list.mat'));
event_filepath = fullfile(main_dir, 'fMRI_conditions_for_high_vs_low.mat');

%% First-level analysis
delete(gcp('nocreate'))
tic

clearvars subject matlabbatch run runbatch subject_event

load(event_filepath); % Loading events

for subject_number = 1 : total_subjects
    clearvars path name ext rp_data
    [path,name,ext] = fileparts(niifiles{subject_number,1});
    rp_data = importdata([fullfile(path, strcat(['rp_' name],'.txt'))]);
    spm_dir = fullfile(path, 'SPM model for high vs low conditions');

    if ~isfolder(spm_dir)
        mkdir(spm_dir);
    else
        delete(fullfile(spm_dir, '*'));
    end

    subject(subject_number).matlabbatch{1}.spm.stats.fmri_spec.dir = {spm_dir};
    subject(subject_number).matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
    subject(subject_number).matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 2;
    subject(subject_number).matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 32;
    subject(subject_number).matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 16;
    
    for run_number = 1 : total_runs
        clearvars path name ext
        [path,name,ext] = fileparts(niifiles{subject_number,run_number});
        subject(subject_number).matlabbatch{1}.spm.stats.fmri_spec.sess(run_number).scans = cellstr([fullfile(path, strcat(['wr' name],ext))]);
        subject(subject_number).matlabbatch{1}.spm.stats.fmri_spec.sess(run_number).cond = subject_event(subject_number).run(run_number).condition;
        subject(subject_number).matlabbatch{1}.spm.stats.fmri_spec.sess(run_number).multi = {''};

%         for reg_number = 1 : size(rp_data, 2)
%             subject(subject_number).matlabbatch{1}.spm.stats.fmri_spec.sess(run_number).regress(reg_number).name = ['Motion' num2str(reg_number)];
%             subject(subject_number).matlabbatch{1}.spm.stats.fmri_spec.sess(run_number).regress(reg_number).val = rp_data(1 + (run_number - 1) * num_of_volumes : run_number * num_of_volumes, reg_number)';
%         end

        writematrix(rp_data(1 + (run_number - 1) * num_of_volumes : run_number * num_of_volumes,:),[fullfile(path, strcat(['divided_rp_' name],'.txt'))]) %, 'Delimiter','\t');

        subject(subject_number).matlabbatch{1}.spm.stats.fmri_spec.sess(run_number).multi_reg = cellstr([fullfile(path, strcat(['divided_rp_' name],'.txt'))]);
        subject(subject_number).matlabbatch{1}.spm.stats.fmri_spec.sess(run_number).hpf = 120;
    
    end
        subject(subject_number).matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
        subject(subject_number).matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [1 1];
        subject(subject_number).matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
        subject(subject_number).matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
end

parpool('local')

parfor subject_number = 1 : total_subjects
    subjectbatch = subject(subject_number).matlabbatch;
    spm_jobman('run',subjectbatch);
end
toc

delete(gcp('nocreate'))

% Model Estimation

delete(gcp('nocreate'))
tic

clearvars subject matlabbatch run runbatch subject_event

load(event_filepath); % Loading events

for subject_number = 1 : total_subjects
    clearvars path name ext
    [path,name,ext] = fileparts(niifiles{subject_number,1});
    spm_dir = fullfile(path, 'SPM model for high vs low conditions');

    subject(subject_number).matlabbatch{1}.spm.stats.fmri_est.spmmat = {fullfile(spm_dir, 'SPM.mat')};
    subject(subject_number).matlabbatch{1}.spm.stats.fmri_est.write_residuals = 0;
    subject(subject_number).matlabbatch{1}.spm.stats.fmri_est.method.Classical = 1;
end

parpool('local')

parfor subject_number = 1 : total_subjects
    subjectbatch = subject(subject_number).matlabbatch;
    spm_jobman('run',subjectbatch);
end
toc

delete(gcp('nocreate'))

%% Contrast Manager

delete(gcp('nocreate'))
tic

clearvars subject matlabbatch run runbatch subject_event SPM condition_contrast weight
num_of_motion_regressors = 6;

condition_contrast =    [1      -1
                         -1     1];

for subject_number = 1 : total_subjects
    clearvars path name ext half_negative_conditions_ind
    [path,name,ext] = fileparts(niifiles{subject_number,1});
    spm_dir = fullfile(path, 'SPM model for high vs low conditions');

    load(fullfile(spm_dir, 'SPM.mat'));
    for condition_numbers = 1 : length(SPM.Sess(1).U)
        subject(subject_number).session.name(condition_numbers) = SPM.Sess(1).U(condition_numbers).name;
    end
    total_num_of_regressors = size(SPM.Sess(1).col, 2);
    num_of_desired_regressors_per_condition = (total_num_of_regressors - num_of_motion_regressors)/length(subject(subject_number).session.name);

    subject(subject_number).matlabbatch{1}.spm.stats.con.spmmat = {fullfile(spm_dir, 'SPM.mat')};
    for contrast_number = 1 : size(condition_contrast,1)
        positive_conditions_ind = find(condition_contrast(contrast_number,:) == 1);
        negative_conditions_ind = find(condition_contrast(contrast_number,:) == -1);
        half_negative_conditions_ind = find(condition_contrast(contrast_number,:) == -0.5);
        if isempty(half_negative_conditions_ind)
            subject(subject_number).matlabbatch{1}.spm.stats.con.consess{contrast_number}.tcon.name = [subject(subject_number).session.name{positive_conditions_ind} ' > ' subject(subject_number).session.name{negative_conditions_ind}];
        else
            subject(subject_number).matlabbatch{1}.spm.stats.con.consess{contrast_number}.tcon.name = [subject(subject_number).session.name{positive_conditions_ind} ' > ' subject(subject_number).session.name{half_negative_conditions_ind(1)}...
                ' & ' subject(subject_number).session.name{half_negative_conditions_ind(2)}];
        end
        for condition_num = 1 : size(condition_contrast, 2)
            weight(condition_num,:) = condition_contrast(contrast_number, condition_num) * ones(1,num_of_desired_regressors_per_condition) / num_of_desired_regressors_per_condition;
        end
        subject(subject_number).matlabbatch{1}.spm.stats.con.consess{contrast_number}.tcon.weights = [reshape(weight.',1,[]) zeros(1,num_of_motion_regressors)];
        subject(subject_number).matlabbatch{1}.spm.stats.con.consess{contrast_number}.tcon.sessrep = 'replsc';

    end
    subject(subject_number).matlabbatch{1}.spm.stats.con.delete = 0;

end

parpool('local')

parfor subject_number = 1 : total_subjects
    subjectbatch = subject(subject_number).matlabbatch;
    spm_jobman('run',subjectbatch);
end
toc

delete(gcp('nocreate'))

%% 2nd Level FFX Specification
params = getParameters();
addpath(params.spm_dir)
spm('defaults','fMRI');

delete(gcp('nocreate'))
tic

clearvars subject matlabbatch run runbatch subject_event SPM spm_dir

total_subjects = params.total_subjects;
main_dir = params.main_dir; % Specify your main directory
load(fullfile(main_dir, 'extracted_file_list.mat'));

second_stat_dir = fullfile(main_dir, 'Second Level Stats for high vs low conditions');

if ~isfolder(second_stat_dir)
    mkdir(second_stat_dir);
else
    delete(fullfile(second_stat_dir, '*'));
end

for subject_number = 1 : total_subjects
    clearvars path name ext
    [path,name,ext] = fileparts(niifiles{subject_number,1});
    spm_dir(subject_number,:) = fullfile(path, 'SPM model for high vs low conditions', 'SPM.mat');
end

matlabbatch{1}.spm.stats.mfx.ffx.dir = {second_stat_dir};
matlabbatch{1}.spm.stats.mfx.ffx.spmmat = cellstr(spm_dir);

spm_jobman('run',matlabbatch);

toc

% Estimate
clearvars; fclose('all');

params = getParameters();
addpath(params.spm_dir)
spm('defaults','fMRI');
tic

main_dir = params.main_dir; % Specify your main directory

second_stat_dir = fullfile(main_dir, 'Second Level Stats for high vs low conditions');

matlabbatch{1}.spm.stats.fmri_est.spmmat = {fullfile(second_stat_dir, 'SPM.mat')};
matlabbatch{1}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{1}.spm.stats.fmri_est.method.Classical = 1;

spm_jobman('run',matlabbatch);
toc
%% Contrast Manager

delete(gcp('nocreate'))
tic

clearvars subject matlabbatch run runbatch subject_event SPM condition_contrast weight
params = getParameters();
num_of_motion_regressors = 6;

condition_contrast =    [1      -1
                         -1     1];

    main_dir = params.main_dir; % Specify your main directory
    spm_dir = fullfile(main_dir, 'Second Level Stats for high vs low conditions');

    load(fullfile(spm_dir, 'SPM.mat'));
    for condition_numbers = 1 : length(SPM.Sess(1).U)
       session.name(condition_numbers) = SPM.Sess(1).U(condition_numbers).name;
    end
    total_num_of_regressors = size(SPM.Sess(1).col, 2);
    num_of_desired_regressors_per_condition = (total_num_of_regressors - num_of_motion_regressors)/length(session.name);

   matlabbatch{1}.spm.stats.con.spmmat = {fullfile(spm_dir, 'SPM.mat')};
    
    for contrast_number = 1 : size(condition_contrast,1)
        positive_conditions_ind = find(condition_contrast(contrast_number,:) == 1);
        negative_conditions_ind = find(condition_contrast(contrast_number,:) == -1);
        half_negative_conditions_ind = find(condition_contrast(contrast_number,:) == -0.5);
        if isempty(half_negative_conditions_ind)
           matlabbatch{1}.spm.stats.con.consess{contrast_number}.tcon.name = [session.name{positive_conditions_ind} ' > ' session.name{negative_conditions_ind}];
        else
           matlabbatch{1}.spm.stats.con.consess{contrast_number}.tcon.name = [session.name{positive_conditions_ind} ' > ' session.name{half_negative_conditions_ind(1)}...
               ' & ' session.name{half_negative_conditions_ind(2)}];
        end
        for condition_num = 1 : size(condition_contrast, 2)
            weight(condition_num,:) = condition_contrast(contrast_number, condition_num) * ones(1,num_of_desired_regressors_per_condition) / num_of_desired_regressors_per_condition;
        end
       matlabbatch{1}.spm.stats.con.consess{contrast_number}.tcon.weights = [reshape(weight.',1,[]) zeros(1,num_of_motion_regressors)];
       matlabbatch{1}.spm.stats.con.consess{contrast_number}.tcon.sessrep = 'replsc';

    end
   matlabbatch{1}.spm.stats.con.delete = 0;




    subjectbatch =matlabbatch;
    spm_jobman('run',subjectbatch);

toc

delete(gcp('nocreate'))

% Results

clearvars subject matlabbatch run runbatch subject_event SPM condition_contrast weight
params = getParameters();
main_dir = params.main_dir; % Specify your main directory
spm_dir = fullfile(main_dir, 'Second Level Stats for high vs low conditions');

condition_contrast =    [1      -1
                         -1     1];

matlabbatch{1}.spm.stats.results.spmmat = {fullfile(spm_dir, 'SPM.mat')};

contrast_number = 1;

    matlabbatch{1}.spm.stats.results.conspec(contrast_number).titlestr = '';
    matlabbatch{1}.spm.stats.results.conspec(contrast_number).contrasts = Inf;
    matlabbatch{1}.spm.stats.results.conspec(contrast_number).threshdesc = 'FWE';
    matlabbatch{1}.spm.stats.results.conspec(contrast_number).thresh = 0.05;
    matlabbatch{1}.spm.stats.results.conspec(contrast_number).extent = 0;
    matlabbatch{1}.spm.stats.results.conspec(contrast_number).conjunction = 1;
    matlabbatch{1}.spm.stats.results.conspec(contrast_number).mask.none = 1;


matlabbatch{1}.spm.stats.results.units = 1;
matlabbatch{1}.spm.stats.results.export{1}.jpg = true;
matlabbatch{1}.spm.stats.results.export{2}.fig = true;

spm_jobman('run',matlabbatch);