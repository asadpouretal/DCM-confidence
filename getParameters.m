function params = getParameters()
    % Define the subfolder identifier for BOLD fMRI data
    params.main_dir = ' ';  % Raw data man folder
    params.spm_dir = 'C:\Toolbox\spm12';                    % Path for SPM12 toolbox
    params.EEGLAB_dir = 'C:\Toolbox\eeglab2023.1';          % Path for EEGLAB toolbox
    params.numWorkers = 2; % number of workers for parallel computing
    params.data_main_dir_pattern = fullfile(params.main_dir, 'sub-'); %Specify subjects data directory pattern
    params.niipattern = {'sub-*_run-01_bold.nii', 'sub-*_run-02_bold.nii'};
    params.num_of_volumes = 771;
    params.EEGpattern = 'EEG_data*run-*.mat';
    params.fiducial = fullfile('additional_files', 'FID.mat');
    params.EEGelectrodeInfo = fullfile(params.main_dir, 'additional_files', 'final_electrodeinfo.elp');
    params.EEGelectrodesfpInfo = fullfile(params.main_dir, 'additional_files','sfp_electrode_info.sfp');
    params.total_subjects = 2; %23;
    params.total_runs = 2;
    params.Epochtimewin = [-100; 2000];
    params.epoched_SPM_pattern = 'Merged_EpochedSPM_Converted_EEG_data_sub';
    params.subjects_to_be_removed = [5 6 11 14 17 19];  % participants withour significant correlation between subjective confidence rating and reaction time
    params.cluster_centroids = {[743 907],[1021 1198], [924 1084], [719 935], [981 1160], [917 1086], [814 998], [1051 1167], [944 1157], [1106 1215], [676 830], [986 1161], [928 1150], [1102 1215], [1081 1214], [1045 1207], [745 927], [999 1142],...
    [1053 1204], [1033 1179], [1026 1161], [691 850], [1025 1182]}; % reaction time thresholds for fast and slow RTs (ms)
    params.DCM_folder_name = 'DCM Models with sustained gaussian input';
    params.inference_folder_pattern = 'Inference for different inputs';
    params.inference_method = 'RFX';
    params.onset_of_DCM_input = 200;    % onset of input in DCM models (ms)
    params.DCM_model_num = [2 2]; % number of models in the model space for each condition
    %% high and low confidence conditions parameters
    params.high_low_condition_name = {'Low confidence', 'High Confidence'};
    params.high_low_result_folder_name = 'Results for High vs Low';
    params.high_low_result_path = fullfile(params.main_dir, params.high_low_result_folder_name);
    params.highlow_Lpos  = [[-42; -52; 56] [-15; -73; 56] [-6; -73; 50] [-42; 26; 38] [39; 41; -1]...
            [-24; 50; 11] [27; 59; 20]];
    params.highlow_Sourcename = {'left Inferior Parietal Lobule', 'left Superior Parietal Lobule',...
            'left Precuneus', 'left Middle Frontal Gyrus', 'right Middle Frontal Gyrus',...
            'left Superior Frontal Gyrus', 'right Superior Frontal Gyrus'};
    params.highlow_winning_model_number = [1, 1]; % winning model for [low confidence, high confidence]
    %% Fast and slow choice-based RT conditions parameters
    params.fast_slow_condition_name = {'Fast RTs', 'Slow RTs'};
    params.fast_slow_result_folder_name = 'Results of Fast vs Slow';
    params.fast_slow_result_path = fullfile(params.main_dir, params.fast_slow_result_folder_name);
    params.fastslow_Lpos  = [[18; -55; 59] [54; -55; 35] [-6; -67; 35] [-39; -13; 56] [-3; -4; 56]];
    params.fastslow_Sourcename = {'right Superior Parietal Lobule', 'right Supramarginal Gyrus',...
            'left Precuneus', 'left Precentral Gyrus', 'left Medial Frontal Gyrus'};
    params.fastslow_winning_model_number = [1, 1]; % winning model for [low confidence, high confidence]
    %% Trial-by-trial analysis parameters
    params.scenarios = {'low vs high confidence ratings', 'fast vs slow choice-based RTs'};
    params.trial_by_trial_analysis_folder = 'trial_by_trial_analysis';
    params.performance_threshold = 0.7;    % Set this to your desired threshold between 0 and 1
    params.correlation_time_window = [0, 400];  % Time window to analyse performance from the onset of each trial in milliseconds
    params.significance_level = 0.05; % For example, 0.001 for a significance level of 0.1%.
    params.number_of_important_feature_permutation = 5;   % try 1250 for defualt
    params.num_permutations = 5;   % try 10000 for default
    params.num_top_features = 10;      % number of top data points with correlation, try 200 for default
    params.sequence_minimum_length = 25;   % minimum length of neural activity sequence in milliseconds including the missing time points
    params.sequence_missing_point_threshold = 25; % maximum number of missing time points in each sequence
    params.actual_sequence_point_threshold = 10;   % minimum timepoint of sustained neural activity in milliseconds exluding the missing time points

end
