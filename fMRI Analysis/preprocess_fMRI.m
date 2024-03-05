function [niifiles, structural_niifiles] = preprocess_fMRI()
    clearvars; fclose('all');
    
    %% Running parallel computing
    
    delete(gcp('nocreate'))
    parpool('local')
    
    %% 
    params = getMRIParameters();
    addpath(params.spm_dir) % add spm12 dir here
    spm('defaults','fMRI');
    
    main_dir = params.main_dir; % Specify your main directory
    data_main_dir = fullfile(main_dir, 'sub-'); %Specify subjects data directory pattern
    matlabbatch = [];
    total_subjects = params.total_subjects;
    total_runs = 2;
    num_of_volumes = 771;
    
    clearvars structural_file subject
    tic
    for subject_number = 1 : total_subjects
    
        if subject_number < 10
            str_subject_number = ['0' num2str(subject_number)];
        else
            str_subject_number = [num2str(subject_number)];
        end
        
        niifiles(subject_number,:) = gunzip(fullfile([data_main_dir str_subject_number], 'func', '*.gz'));
       
        
        structural_niifiles(subject_number,:) = gunzip(fullfile([data_main_dir str_subject_number], 'anat', '*.gz'));
    
    
    
    %     structural_filepath = [data_main_dir str_subject_number
    %     '\anat\sub-' str_subject_number '_T1map_defaced.nii'];
    
        structural_filepath = structural_niifiles{subject_number};
    
        
        subject(subject_number).matlabbatch{1}.spm.spatial.realign.estwrite.data = {cellstr(vertcat(niifiles{subject_number,:}))};
        subject(subject_number).matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
        subject(subject_number).matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.sep = 4;
        subject(subject_number).matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.fwhm = 5;
        subject(subject_number).matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.rtm = 0;
        subject(subject_number).matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.interp = 2;
        subject(subject_number).matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
        subject(subject_number).matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.weight = '';
        subject(subject_number).matlabbatch{1}.spm.spatial.realign.estwrite.roptions.which = [2 1];
        subject(subject_number).matlabbatch{1}.spm.spatial.realign.estwrite.roptions.interp = 4;
        subject(subject_number).matlabbatch{1}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
        subject(subject_number).matlabbatch{1}.spm.spatial.realign.estwrite.roptions.mask = 1;
        subject(subject_number).matlabbatch{1}.spm.spatial.realign.estwrite.roptions.prefix = 'r';
    
    % Co-registration based on SPM manual
        
        [path,name,ext] = fileparts(niifiles(subject_number,:));
        subject(subject_number).matlabbatch{2}.spm.spatial.coreg.estimate.ref = cellstr([fullfile(path{1}, strcat(['mean' name{1}],ext{1}))]);
        subject(subject_number).matlabbatch{2}.spm.spatial.coreg.estimate.source = cellstr(structural_filepath);
        subject(subject_number).matlabbatch{2}.spm.spatial.coreg.estimate.other = {''};
        subject(subject_number).matlabbatch{2}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
        subject(subject_number).matlabbatch{2}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
        subject(subject_number).matlabbatch{2}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
        subject(subject_number).matlabbatch{2}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];
    %     
    %         % write EPIs
    
    %     subject(subject_number).matlabbatch{3}.spm.spatial.realign.write.data
    %     = cellstr(vertcat(niifiles{subject_number,:}));
    %     subject(subject_number).matlabbatch{3}.spm.spatial.realign.write.roptions.which
    %     = [2 1];%all images as well as the mean image.
    %     subject(subject_number).matlabbatch{3}.spm.spatial.realign.write.roptions.interp
    %     = 4;
    %     subject(subject_number).matlabbatch{3}.spm.spatial.realign.write.roptions.wrap
    %     = [0 0 0];
    %     subject(subject_number).matlabbatch{3}.spm.spatial.realign.write.roptions.mask
    %     = 1;
    %     subject(subject_number).matlabbatch{3}.spm.spatial.realign.write.roptions.prefix
    %     = 'r';
    end
    
    parfor subject_number = 1 : total_subjects
        subjectbatch = subject(subject_number).matlabbatch;
        spm_jobman('run',subjectbatch);
    end
    toc
    
    delete(gcp('nocreate'))
    
    tic
    clearvars subject
    
    for subject_number = 1 : total_subjects
            
            structural_filepath = structural_niifiles{subject_number};
            
            subject(subject_number).matlabbatch{1}.spm.spatial.preproc.channel.vols = cellstr(structural_filepath);
            subject(subject_number).matlabbatch{1}.spm.spatial.preproc.channel.biasreg = 0.001;
            subject(subject_number).matlabbatch{1}.spm.spatial.preproc.channel.biasfwhm = 60;
            subject(subject_number).matlabbatch{1}.spm.spatial.preproc.channel.write = [0 1];
            subject(subject_number).matlabbatch{1}.spm.spatial.preproc.tissue(1).tpm = {fullfile(spm12_folder, 'tpm', 'TPM.nii,1')};
            subject(subject_number).matlabbatch{1}.spm.spatial.preproc.tissue(1).ngaus = 1;
            subject(subject_number).matlabbatch{1}.spm.spatial.preproc.tissue(1).native = [1 0];
            subject(subject_number).matlabbatch{1}.spm.spatial.preproc.tissue(1).warped = [0 0];
            subject(subject_number).matlabbatch{1}.spm.spatial.preproc.tissue(2).tpm = {fullfile(spm12_folder, 'tpm', 'TPM.nii,2')};
            subject(subject_number).matlabbatch{1}.spm.spatial.preproc.tissue(2).ngaus = 1;
            subject(subject_number).matlabbatch{1}.spm.spatial.preproc.tissue(2).native = [1 0];
            subject(subject_number).matlabbatch{1}.spm.spatial.preproc.tissue(2).warped = [0 0];
            subject(subject_number).matlabbatch{1}.spm.spatial.preproc.tissue(3).tpm = {fullfile(spm12_folder, 'tpm', 'TPM.nii,3')};
            subject(subject_number).matlabbatch{1}.spm.spatial.preproc.tissue(3).ngaus = 2;
            subject(subject_number).matlabbatch{1}.spm.spatial.preproc.tissue(3).native = [1 0];
            subject(subject_number).matlabbatch{1}.spm.spatial.preproc.tissue(3).warped = [0 0];
            subject(subject_number).matlabbatch{1}.spm.spatial.preproc.tissue(4).tpm = {fullfile(spm12_folder, 'tpm', 'TPM.nii,4')};
            subject(subject_number).matlabbatch{1}.spm.spatial.preproc.tissue(4).ngaus = 3;
            subject(subject_number).matlabbatch{1}.spm.spatial.preproc.tissue(4).native = [1 0];
            subject(subject_number).matlabbatch{1}.spm.spatial.preproc.tissue(4).warped = [0 0];
            subject(subject_number).matlabbatch{1}.spm.spatial.preproc.tissue(5).tpm = {fullfile(spm12_folder, 'tpm', 'TPM.nii,5')};
            subject(subject_number).matlabbatch{1}.spm.spatial.preproc.tissue(5).ngaus = 4;
            subject(subject_number).matlabbatch{1}.spm.spatial.preproc.tissue(5).native = [1 0];
            subject(subject_number).matlabbatch{1}.spm.spatial.preproc.tissue(5).warped = [0 0];
            subject(subject_number).matlabbatch{1}.spm.spatial.preproc.tissue(6).tpm = {fullfile(spm12_folder, 'tpm', 'TPM.nii,6')};
            subject(subject_number).matlabbatch{1}.spm.spatial.preproc.tissue(6).ngaus = 2;
            subject(subject_number).matlabbatch{1}.spm.spatial.preproc.tissue(6).native = [0 0];
            subject(subject_number).matlabbatch{1}.spm.spatial.preproc.tissue(6).warped = [0 0];
            subject(subject_number).matlabbatch{1}.spm.spatial.preproc.warp.mrf = 1;
            subject(subject_number).matlabbatch{1}.spm.spatial.preproc.warp.cleanup = 1;
            subject(subject_number).matlabbatch{1}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
            subject(subject_number).matlabbatch{1}.spm.spatial.preproc.warp.affreg = 'mni';
            subject(subject_number).matlabbatch{1}.spm.spatial.preproc.warp.fwhm = 0;
            subject(subject_number).matlabbatch{1}.spm.spatial.preproc.warp.samp = 3;
            subject(subject_number).matlabbatch{1}.spm.spatial.preproc.warp.write = [0 1];
            subject(subject_number).matlabbatch{1}.spm.spatial.preproc.warp.vox = NaN;
            subject(subject_number).matlabbatch{1}.spm.spatial.preproc.warp.bb = [NaN NaN NaN
                                                          NaN NaN NaN];
    end
    parpool('local')
    
    parfor subject_number = 1 : total_subjects
        subjectbatch = subject(subject_number).matlabbatch;
        spm_jobman('run',subjectbatch);
    end
    toc
    
    delete(gcp('nocreate'))
        %% Functional Normalization
    delete(gcp('nocreate'))
    tic
    clearvars subject matlabbatch run runbatch
    
    for run_number = 1 : total_runs
        for subject_number = 1 : total_subjects
    
            clearvars path name ext
            structural_filepath = structural_niifiles{subject_number};
            [path,name,ext] = fileparts(structural_filepath);
    
            run(run_number).matlabbatch{1}.spm.spatial.normalise.write.subj(subject_number).def = cellstr([fullfile(path, strcat(['y_' name],ext))]);
            
            clearvars path name ext
            [path,name,ext] = fileparts(niifiles{subject_number,run_number});
            run(run_number).matlabbatch{1}.spm.spatial.normalise.write.subj(subject_number).resample = cellstr([fullfile(path, strcat(['r' name],ext))]);
        end
            run(run_number).matlabbatch{1}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70
                                                                      78 76 85];
            run(run_number).matlabbatch{1}.spm.spatial.normalise.write.woptions.vox = [3 3 3];
            run(run_number).matlabbatch{1}.spm.spatial.normalise.write.woptions.interp = 4;
            run(run_number).matlabbatch{1}.spm.spatial.normalise.write.woptions.prefix = 'w';
    
    end
    
    parpool('local')
    
    parfor run_number = 1 : total_runs
        runbatch = run(run_number).matlabbatch;
        spm_jobman('run',runbatch);
    end
    toc
    
    delete(gcp('nocreate'))  
        %% Structural Normalization
    delete(gcp('nocreate'))
    tic
    clearvars subject matlabbatch run runbatch
    
    for run_number = 1 : total_runs
        for subject_number = 1 : total_subjects
    
            clearvars path name ext
            structural_filepath = structural_niifiles{subject_number};
            [path,name,ext] = fileparts(structural_filepath);
            run(run_number).matlabbatch{1}.spm.spatial.normalise.write.subj(subject_number).def = cellstr([fullfile(path, strcat(['y_' name],ext))]);
            run(run_number).matlabbatch{1}.spm.spatial.normalise.write.subj(subject_number).resample = cellstr([fullfile(path, strcat(['m' name],ext))]);
        end
            run(run_number).matlabbatch{1}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70
                                                                      78 76 85];
            run(run_number).matlabbatch{1}.spm.spatial.normalise.write.woptions.vox = [1 1 3];
            run(run_number).matlabbatch{1}.spm.spatial.normalise.write.woptions.interp = 4;
            run(run_number).matlabbatch{1}.spm.spatial.normalise.write.woptions.prefix = 'w';
    end
    parpool('local')
    
    parfor run_number = 1 : total_runs
        runbatch = run(run_number).matlabbatch;
        spm_jobman('run',runbatch);
    end
    toc
    
    delete(gcp('nocreate'))  

    save(fullfile(main_dir, 'extracted_file_list.mat'),"niifiles","structural_niifiles");
end