close all; clearvars;

params = getMRIParameters();

main_dir = params.main_dir; % Specify your main directory
data_main_dir = params.data_main_dir_pattern; %Specify subjects data directory pattern

condition_name = {'Fast Reactions', 'Slow Reaction'};
reaction_time_threshold = {852, 1061};
trial_type = {'dot_stim_validtrials', 'dot_resp_validtrials', 'rating_stim_validtrials'};
fixed_condition_duration = 1.4; % Second

%     eeglab
%     close
total_subjects = params.total_subjects;
total_runs = 2;

Cluster_Centroids = params.cluster_centroids;

for run_number = 1 : total_runs
    FileInfo = dir(fullfile(main_dir, '**', 'EEG', ['EEG_data*run-0' num2str(run_number) '.mat']));
    % delete(gcp('nocreate'))
    % parpool('local')
    
    for subject_number = 1 : total_subjects
    
        clearvars filename pathname C

            if subject_number < 10
                str_subject_number = ['0' num2str(subject_number)];
            else
                str_subject_number = [num2str(subject_number)];
            end
    
        filename = FileInfo(subject_number).name;
        pathname = FileInfo(subject_number).folder;
        event_pathname = fullfile(main_dir, 'EEG_events_EEGfMRI');
    %     [filename, pathname] = uigetfile({'*.mat'},'Select a .mat file to load your fMRI Acquisition data from','F:\Raw Data\fMRI - EEG\Sabina''s Decision Making\sub-01\EEG');
%         fullFileName_Data = fullfile(pathname, filename);
%         load(fullFileName_Data);

        subject_event(subject_number).run(run_number).fMRI_events = readcell(fullfile(main_dir, ['sub-' str_subject_number], 'func', ['sub-' str_subject_number '_task-main_run-0' num2str(run_number) '_events.tsv']), 'FileType', 'text');
       
        %% Event Definition
        EEG.Event_Types = ['Stimilus', 'Response', 'Confidence'];
        EEG.Low_Confidence_Thrd = 5;
        EEG.Medium_Confidence_Thrd = 7;
        EEG.High_Confidence_Thrd = 11;
        
        
        Event_filename = strrep(filename,'EEG_data','EEG_events');
        
        Event_fullFileName_Data = fullfile(event_pathname, Event_filename);
        load(Event_fullFileName_Data);
        
        subject_event(subject_number).run(run_number).RT = RT;
    
        subject_event(subject_number).run(run_number).cond.ind{1} = find(RT < Cluster_Centroids{subject_number}(1));
        subject_event(subject_number).run(run_number).cond.ind{2} = find(RT > Cluster_Centroids{subject_number}(2));

        subject_event(subject_number).run(run_number).fMRI_all_stim_events_onsets = subject_event(subject_number).run(run_number).fMRI_events(...
            find(contains(subject_event(subject_number).run(run_number).fMRI_events(:,4),trial_type{1})),1:2);

        for condition_number = 1 : length(condition_name)
            subject_event(subject_number).run(run_number).condition(condition_number).name = condition_name{condition_number};
            subject_event(subject_number).run(run_number).condition(condition_number).onset = cell2mat(subject_event(subject_number).run(run_number).fMRI_all_stim_events_onsets(...
                subject_event(subject_number).run(run_number).cond.ind{condition_number},1));
            subject_event(subject_number).run(run_number).condition(condition_number).duration = cell2mat(subject_event(subject_number).run(run_number).fMRI_all_stim_events_onsets(...
                subject_event(subject_number).run(run_number).cond.ind{condition_number},2));
            subject_event(subject_number).run(run_number).condition(condition_number).tmod = 0;
            subject_event(subject_number).run(run_number).condition(condition_number).pmod = struct('name', {}, 'param', {}, 'poly', {});
            subject_event(subject_number).run(run_number).condition(condition_number).orth = 1;
        end

    end
end

full_RT = [];

for subject_number = 1 : length(subject_event)
    for run_number = 1 : total_runs
        RT_temp = [subject_number*ones(1,length(subject_event(subject_number).run(run_number).RT)) ; subject_event(subject_number).run(run_number).RT];
        full_RT = [full_RT RT_temp];
    end
end

full_RT = full_RT';

save(fullfile(main_dir, 'fMRI_conditions_for_fast_vs_slow.mat'),"subject_event", "full_RT", "Cluster_Centroids");