clear; close all;
restoredefaultpath;
params = getParameters();

addpath(params.spm_dir) % add spm path to MATLAB path
addpath(params.EEGLAB_dir)  % add EEGLAB path to MATLAB path
spm('defaults','EEG');
delete(gcp('nocreate'))

main_dir = params.main_dir; % main data folder
FileInfo = dir(fullfile(main_dir, '**', 'EEG', params.EEGpattern));
FileInfo = FileInfo(1:params.total_subjects * params.total_runs);
result_path = params.high_low_result_path;
Event_Path = fullfile(main_dir, 'EEG_events_EEGfMRI');
Event_Types = ['Stimulation', 'Interphase', 'Rating'];
defaultProfileName = parallel.defaultClusterProfile;

%     eeglab
%     close

for EEG_File_Number = 1 : length(FileInfo)

    clearvars -except FileInfo EEG_File_Number Event_Types Event_Path result_path main_dir SPM_Path SPM_Ready_File SPM_output params defaultProfileName
    eeglab
    close
    close all
    filename = FileInfo(EEG_File_Number).name;
    pathname = FileInfo(EEG_File_Number).folder;
    
    
%     [filename, pathname] = uigetfile({'*.mat'},'Select a .mat file to load your fMRI Acquisition data from','F:\Raw Data\fMRI - EEG\Sabina''s Decision Making\sub-01\EEG');
    fullFileName_Data = fullfile(pathname, filename);
    load(fullFileName_Data);
    load(fullfile(main_dir, params.fiducial));
    if ~isempty(excludedchannels)
        for Channels = 1 : length(excludedchannels)
            NewRow = zeros(1 , size(EEGdata.Y, 2));
            EEGdata.Y = [EEGdata.Y(1:excludedchannels(Channels)-1,:) ; NewRow ; EEGdata.Y(excludedchannels(Channels) : end, :)];
        end
    end
    
    EEG = pop_importdata('setname', filename, 'data', EEGdata.Y, 'dataformat', 'array', 'srate', EEGdata.fd);
    EEG = pop_chanedit(EEG,'load', {params.EEGelectrodeInfo});
    EEG = pop_interp(EEG, excludedchannels);
    
    EEG = pop_select(EEG, 'nochannel', {'NFpz'});
    %% Event Definition
    EEG.Event_Types = Event_Types;
    EEG.Low_Confidence_Thrd = 5;
    EEG.Medium_Confidence_Thrd = 7;
    EEG.High_Confidence_Thrd = 11;
    
    
    Event_filename = strrep(filename,'EEG_data','EEG_events');
    
    Event_fullFileName_Data = fullfile(Event_Path, Event_filename);
    load(Event_fullFileName_Data);
    
%     tstim = accuracy.*tstim; tstim(tstim == 0) = [];
%     tresp = accuracy.*tresp; tresp(tresp == 0) = [];
%     tconf = accuracy.*tconf; tconf(tconf == 0) = [];
%     choice = accuracy.*choice; choice(choice == 0) = [];
%     confidence = accuracy.*confidence; confidence(confidence == 0) = [];
%     accuracy(accuracy == 0) = [];

    Conficence_Value(confidence < EEG.Low_Confidence_Thrd) = 'L';
    Conficence_Value(confidence > (EEG.Low_Confidence_Thrd - 1) & confidence < EEG.Medium_Confidence_Thrd) = 'M';
    Conficence_Value(confidence > (EEG.Medium_Confidence_Thrd - 1) & confidence < EEG.High_Confidence_Thrd) = 'H';
    
    Confidence_Stimulus = cellstr(Conficence_Value');
    
    Event_Latency = num2cell([tstim' ; tresp'; (tconf)']/EEG.srate);
    Event_Type = repelem([{EEG.Event_Types(1)}, {EEG.Event_Types(2)}, {EEG.Event_Types(3)}], [length(tstim) length(tresp) length(tconf)])';
    % Event_Value = num2cell([accuracy' ; choice'; confidence']);
%     Event_Value = num2cell([choice'; confidence']);
    Event_Value = [Confidence_Stimulus ;Confidence_Stimulus; Confidence_Stimulus];
    Event = [Event_Value, Event_Latency, Event_Type ];
    
    
    EEG = pop_importevent( EEG, 'event', Event, 'fields', { 'type', 'latency', 'value' });
    %% Convert to SPM Format
    [folder, baseFileNameNoExt, extension] = fileparts(fullFileName_Data);
    
    SPM_Path{EEG_File_Number} = fullfile(result_path, 'SPM Analyses', baseFileNameNoExt);
    
    if ~isfolder(SPM_Path{EEG_File_Number})
        mkdir(SPM_Path{EEG_File_Number});
    end
    SPM_Ready_filename = ['SPM_Ready_' baseFileNameNoExt];
    SPM_Ready_File{EEG_File_Number} = fullfile(SPM_Path{EEG_File_Number}, SPM_Ready_filename);
    
    EEG = pop_saveset( EEG, 'filename', SPM_Ready_filename, 'filepath', SPM_Path{EEG_File_Number}); % no pop-up
    % save(SPM_Ready_File,"EEG");
    SPM_output{EEG_File_Number} = fullfile(SPM_Path{EEG_File_Number}, ['SPM_Converted_' baseFileNameNoExt]);
end
    %--------------------------------------------------------------------------
    save(fullfile(main_dir, 'eeglab_analysed_data_files.mat'),"SPM_output","SPM_Ready_File","SPM_Path")

    spm('defaults','EEG');

for file_number = 1 : length(SPM_Ready_File)
    subject_run(file_number).matlabbatch{1}.spm.meeg.convert.dataset = {[SPM_Ready_File{file_number} '.set']};
    subject_run(file_number).matlabbatch{1}.spm.meeg.convert.mode.continuous.readall = 1;
    subject_run(file_number).matlabbatch{1}.spm.meeg.convert.channels{1}.all = 'all';
    subject_run(file_number).matlabbatch{1}.spm.meeg.convert.outfile = SPM_output{file_number};
    subject_run(file_number).matlabbatch{1}.spm.meeg.convert.eventpadding = 0;
    subject_run(file_number).matlabbatch{1}.spm.meeg.convert.blocksize = 3276800;
    subject_run(file_number).matlabbatch{1}.spm.meeg.convert.checkboundary = 1;
    subject_run(file_number).matlabbatch{1}.spm.meeg.convert.saveorigheader = 0;
    subject_run(file_number).matlabbatch{1}.spm.meeg.convert.inputformat = 'eeglab_set';
end

parpool(defaultProfileName)

parfor subject_number = 1 : length(SPM_Ready_File)
    subjectbatch = subject_run(subject_number).matlabbatch;
    spm_jobman('run',subjectbatch);
end

%    cd(SPM_Path)
    
    %% Assigning Sensor Locations
    
    clearvars matlabbatch subject_run

for file_number = 1 : length(SPM_Ready_File)    
    subject_run(file_number).matlabbatch{1}.spm.meeg.preproc.prepare.D = {[SPM_output{file_number} '.mat']};
    subject_run(file_number).matlabbatch{1}.spm.meeg.preproc.prepare.task{1}.loadeegsens.eegsens = {params.EEGelectrodesfpInfo};
    subject_run(file_number).matlabbatch{1}.spm.meeg.preproc.prepare.task{1}.loadeegsens.megmatch.matching(1).fidname = 'nas';
    subject_run(file_number).matlabbatch{1}.spm.meeg.preproc.prepare.task{1}.loadeegsens.megmatch.matching(1).hsname = 'nas';
    subject_run(file_number).matlabbatch{1}.spm.meeg.preproc.prepare.task{1}.loadeegsens.megmatch.matching(2).fidname = 'lpa';
    subject_run(file_number).matlabbatch{1}.spm.meeg.preproc.prepare.task{1}.loadeegsens.megmatch.matching(2).hsname = 'LPA';
    subject_run(file_number).matlabbatch{1}.spm.meeg.preproc.prepare.task{1}.loadeegsens.megmatch.matching(3).fidname = 'rpa';
    subject_run(file_number).matlabbatch{1}.spm.meeg.preproc.prepare.task{1}.loadeegsens.megmatch.matching(3).hsname = 'RPA';
end

% parpool(defaultProfileName)

parfor subject_number = 1 : length(SPM_Ready_File)
    subjectbatch = subject_run(subject_number).matlabbatch;
    spm_jobman('run',subjectbatch);
end

    clearvars matlabbatch subject_run
for file_number = 1 : length(SPM_Ready_File)     
    subject_run(file_number).matlabbatch{1}.spm.meeg.preproc.prepare.D = {[SPM_output{file_number} '.mat']};
    subject_run(file_number).matlabbatch{1}.spm.meeg.preproc.prepare.task{1}.defaulteegsens.multimodal.nasfid = 'nas';
    subject_run(file_number).matlabbatch{1}.spm.meeg.preproc.prepare.task{1}.defaulteegsens.multimodal.lpafid = 'LPA';
    subject_run(file_number).matlabbatch{1}.spm.meeg.preproc.prepare.task{1}.defaulteegsens.multimodal.rpafid = 'RPA';
end
    
parfor subject_number = 1 : length(SPM_Ready_File)
    subjectbatch = subject_run(subject_number).matlabbatch;
    spm_jobman('run',subjectbatch);
end
    
    %% Epoching SPM File 
    clearvars matlabbatch subject_run
for subject_number = 1 : length(SPM_output)
    subject_run(subject_number).S.D = [SPM_output{subject_number} '.mat'];
    subject_run(subject_number).S.timewin = params.Epochtimewin;
    
    subject_run(subject_number).S.trialdef(1).conditionlabel = params.high_low_condition_name{1};
    subject_run(subject_number).S.trialdef(1).eventtype = Event_Types(1);
    subject_run(subject_number).S.trialdef(1).eventvalue = 'L';
    subject_run(subject_number).S.trialdef(1).trlshift = 0;
    
    subject_run(subject_number).S.trialdef(2).conditionlabel = params.high_low_condition_name{2};
    subject_run(subject_number).S.trialdef(2).eventtype = Event_Types(1);
    subject_run(subject_number).S.trialdef(2).eventvalue = 'H';
    subject_run(subject_number).S.trialdef(2).trlshift = 0;
    
    subject_run(subject_number).S.save = 1;
    subject_run(subject_number).S.prefix = 'Epoched';
    subject_run(subject_number).S.bc = 1;
end
clearvars S D

for subject_number = 1 : length(SPM_output)
    S = subject_run(subject_number).S;
    D = spm_eeg_epochs(S);
end

%% Merging same subject's SPM Files
clearvars matlabbatch subject_run
subject_number = 1;
num_of_run = params.total_runs;
for file_number = 1 : num_of_run : (length(SPM_output) - 1)
    sessionfilenames = [];
    for run_number = 1 : num_of_run
    [folder, filename, ext] = fileparts([SPM_output{file_number - 1 + run_number} '.mat']);
    sessionfilenames = [sessionfilenames
                        fullfile(folder,['Epoched' filename ext])];
    end

    subject_run(subject_number).folder = folder;
    subject_run(subject_number).S.D = sessionfilenames;
    subject_run(subject_number).S.recode = 'same';
    subject_run(subject_number).S.prefix = 'Merged_';
    subject_number = subject_number + 1;
end

clearvars S D

parfor subject = 1 : subject_number - 1
    cd(subject_run(subject).folder)
    S = subject_run(subject).S;
    D = spm_eeg_merge(S);
end

%% Deleting all files except for Merged_ files

filelist = dir(fullfile(result_path, '**', '*.*'));
filelist = filelist(~startsWith({filelist.name}, 'Merged_'));
tf1 = [filelist.isdir];
filelist = filelist(tf1 == 0);

for file_num = 1 : length(filelist)
    delete(fullfile(filelist(file_num).folder, filelist(file_num).name));
end