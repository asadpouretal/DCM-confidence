% analyse some ERP data 

% To try this out on your data ), 
% you have to change 'Pbase' to your own analysis-directory, and choose a name ('DCM.xY.Dfile') 
% of an existing SPM for M/EEG-file with at least two evoked responses. 

% Please replace filenames etc. by your own.
%--------------------------------------------------------------------------
clear; close all;
restoredefaultpath;
params = getParameters();

addpath(params.spm_dir) % add spm path to MATLAB path
addpath(params.EEGLAB_dir)  % add EEGLAB path to MATLAB path
spm('defaults','EEG');
spm; close;
delete(gcp('nocreate'));
defaultProfileName = parallel.defaultClusterProfile;

jobStorageLocation = fullfile(params.main_dir, 'ParallelJobStorage'); % Replace with your actual job storage location

spm('defaults','EEG');

% Data and analysis directories
%--------------------------------------------------------------------------
scenario_number = 1;            % 1: high vs low confidence; 2: fast vs slow responses; 3: rating vs stimulation phase
trial_by_trial = 1;         % trial by trial analysis
variables_for_scenario = scenario_variables(scenario_number);   % get scenario variables
condition_name = variables_for_scenario.condition_name;

if trial_by_trial
    DCM_parent_folder = variables_for_scenario.trial_DCM_folder;
end

num_of_subjects = params.total_subjects;
onset_of_input = params.onset_of_DCM_input;
residual_time = 261;


poolobj = gcp('nocreate');
delete(poolobj);

existingProfiles = parallel.clusterProfiles();
profileName = existingProfiles{1};
numWorkers = params.numWorkers; % Number of workers you want to specify
matlabRoot = matlabroot; % Replace with your actual MATLAB root directory


modifyCustomParallelProfile(profileName, numWorkers, matlabRoot, jobStorageLocation);

if trial_by_trial
    % Start the parallel pool
    poolObj = parpool(profileName, numWorkers);
end

for condition = 1 : length(condition_name)
    current_condition = condition_name{condition};
    DCM_folder = [DCM_parent_folder filesep condition_name{condition}];
    Cluster_Centroids = {[743 907],[1021 1198], [924 1084], [719 935], [981 1160], [917 1086], [814 998], [1051 1167], [944 1157], [1106 1215], [676 830], [986 1161], [928 1150], [1102 1215], [1081 1214], [1045 1207], [745 927], [999 1142],...
        [1053 1204], [1033 1179], [1026 1161], [691 850], [1025 1182]};
    
    Pbase     = variables_for_scenario.Pbase;        % directory with your data, 
    for subject_number = 1 : num_of_subjects
        if subject_number < 10
            Pdata     = fullfile(Pbase, ['EEG_data_sub-0' num2str(subject_number) '_run-02']); % data directory in Pbase
            Panalysis = fullfile(Pbase, DCM_folder, ['EEG_data_sub-0' num2str(subject_number) '_run-02']); % analysis directory in Pbase
        else
            Pdata     = fullfile(Pbase, ['EEG_data_sub-' num2str(subject_number) '_run-02']); % data directory in Pbase
            Panalysis = fullfile(Pbase, DCM_folder, ['EEG_data_sub-' num2str(subject_number) '_run-02']); % analysis directory in Pbase
        end
        
        DCM = [];
        % Data filename
        %--------------------------------------------------------------------------
        if subject_number < 10
            DCM.xY.Dfile = fullfile(Pdata, ['Merged_EpochedSPM_Converted_EEG_data_sub-0' num2str(subject_number) '_run-01.mat']);
        else
            DCM.xY.Dfile = fullfile(Pdata, ['Merged_EpochedSPM_Converted_EEG_data_sub-' num2str(subject_number) '_run-01.mat']);
        end
        
        % Parameters and options used for setting up model
        %--------------------------------------------------------------------------
        DCM.options.analysis = 'ERP'; % analyze evoked responses
        DCM.options.model    = 'CMC'; % ERP model
        DCM.options.spatial  = 'IMG'; % spatial model
        DCM.options.trials   = [condition];   % index of ERPs within ERP/ERF file
        DCM.options.Tdcm(1)  = -50;     % start of peri-stimulus time to be modelled
        DCM.options.Tdcm(2)  = 1200;   % end of peri-stimulus time to be modelled
        DCM.options.Nmodes   = 8;     % nr of modes for data selection
        DCM.options.h        = 1;     % nr of DCT components
        DCM.options.onset    = [onset_of_input];    % selection of onset (prior mean)
        DCM.options.dur      = [16];    % selection of onset (prior mean) 
        DCM.options.D        = 1;     % downsampling
        DCM.options.Nmax     = 80;     % maxiumum number of iterations
        DCM.options.DATA     = 0;       % not saving the estimated DCMs
        DCM.M.sus            = 1;
        %--------------------------------------------------------------------------
        % Data and spatial model
        %--------------------------------------------------------------------------
        if trial_by_trial
            DCM  = spm_dcm_erp_data(DCM, 0);
        end
        
        %--------------------------------------------------------------------------
        % Location priors for dipoles
        %--------------------------------------------------------------------------
        if trial_by_trial
            DCM = get_trial_DCM_parameters(DCM, current_condition);
        end            
        
        %--------------------------------------------------------------------------
        % Spatial model
        %--------------------------------------------------------------------------
        DCM = spm_dcm_erp_dipfit(DCM);
        DCM.M.sus            = 1;
        DCM_temp = DCM;
        
        %--------------------------------------------------------------------------
        % Specify connectivity model
        %--------------------------------------------------------------------------
        if ~isfolder(Panalysis)
            mkdir(Panalysis);
        end

        
        if trial_by_trial
            DCM = get_trial_DCM_parameters(DCM, current_condition);
            cd(Panalysis)
            n_trials = DCM.xY.nt;
            out_DCM = cell(n_trials, 1);
            parfor trial = 1 : n_trials
                trial_DCM = DCM;
                trial_DCM.xY.y = {DCM.xY.y{1}(:,:, trial)};
                out_DCM{trial}      = spm_dcm_erp(trial_DCM);
            end
            DCM_output_file_name = 'trial_DCM.mat';
        end
        save(fullfile(Panalysis, DCM_output_file_name), "out_DCM", '-v7.3');
    end
end

%% clean up
rmpath(params.spm_dir, params.EEGLAB_dir);

% Optionally, delete the pool when you're done
delete(poolObj);