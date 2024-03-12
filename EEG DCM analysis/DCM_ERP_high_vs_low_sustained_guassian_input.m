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
delete(gcp('nocreate'));
defaultProfileName = parallel.defaultClusterProfile;


% Data and analysis directories
%--------------------------------------------------------------------------
condition_name = params.high_low_condition_name;

num_of_subjects = params.total_subjects;
onset_of_input = params.onset_of_DCM_input;
parpool(defaultProfileName, params.numWorkers);

for condition = 1 : length(condition_name)

    DCM_folder = [params.DCM_folder_name filesep condition_name{condition}];
    Cluster_Centroids = params.cluster_centroids;
    
    Pbase     = fullfile(params.high_low_result_path, 'SPM Analyses'); % directory with your data, 
    parfor subject_number = 1 : num_of_subjects
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
            DCM.xY.Dfile = fullfile(Pdata, [params.epoched_SPM_pattern '-0' num2str(subject_number) '_run-01.mat']);
        else
            DCM.xY.Dfile = fullfile(Pdata, [params.epoched_SPM_pattern '-' num2str(subject_number) '_run-01.mat']);
        end
        
        % Parameters and options used for setting up model
        %--------------------------------------------------------------------------
        DCM.options.analysis = 'ERP'; % analyze evoked responses
        DCM.options.model    = 'CMC'; % ERP model
        DCM.options.spatial  = 'IMG'; % spatial model
        DCM.options.trials   = [condition];   % index of ERPs within ERP/ERF file
        DCM.options.Tdcm(1)  = -50;     % start of peri-stimulus time to be modelled
        DCM.options.Tdcm(2)  = 800;   % end of peri-stimulus time to be modelled
        DCM.options.Nmodes   = 8;     % nr of modes for data selection
        DCM.options.h        = 1;     % nr of DCT components
        DCM.options.onset    = [onset_of_input];    % selection of onset (prior mean)
        DCM.options.dur      = [16];    % selection of onset (prior mean) 
        DCM.options.D        = 1;     % downsampling
        DCM.options.Nmax     = 128;     % maxiumum number of iterations
        DCM.M.sus            = 1;       % using sustained Gaussian input
        %--------------------------------------------------------------------------
        % Data and spatial model
        %--------------------------------------------------------------------------
        DCM  = spm_dcm_erp_data(DCM);
        
        %--------------------------------------------------------------------------
        % Location priors for dipoles
        %--------------------------------------------------------------------------
        DCM.Lpos  = params.highlow_Lpos;
        DCM.Sname = params.highlow_Sourcename;
        Nareas    = size(DCM.Lpos,2);
        
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
        cd(Panalysis)
        
        
        DCM.A{1} = zeros(Nareas,Nareas);
        DCM.A{2} = zeros(Nareas, Nareas);
        DCM.A{1}(2,1) = 1;
        DCM.A{1}(3,1) = 1;
        DCM.A{1}(3,2) = 1;
        DCM.A{1}(4,3) = 1;
        DCM.A{1}(6,4) = 1;
        DCM.A{1}(5,4) = 1;
        DCM.A{1}(7,5) = 1;
        DCM.A{1}(7,6) = 1;
        
        DCM.A{2} = DCM.A{1}.';
        
        DCM.A{3} = zeros(Nareas,Nareas);
        Modulatory_self_connection = [];
        Modulatory_self_connection = ones(1, Nareas);
        DCM.A{3} = diag(Modulatory_self_connection);
    
        DCM.C = [1; 1; 0; 0; 0; 0; 0];
        
        %--------------------------------------------------------------------------
        % Between trial effects
        %--------------------------------------------------------------------------
        
        %--------------------------------------------------------------------------
        % Invert
        %--------------------------------------------------------------------------
        DCM.name = 'DCM_CMC_M1';
        
        DCM      = spm_dcm_erp(DCM);
    
    
        %--------------------------------------------------------------------------
        % Specify connectivity model for M2
        %--------------------------------------------------------------------------  
        DCM = DCM_temp;
        cd(Panalysis)
        
        
        DCM.A{1} = zeros(Nareas,Nareas);
        DCM.A{2} = zeros(Nareas, Nareas);
        DCM.A{1}(2,1) = 1;
        DCM.A{1}(3,1) = 1;
        DCM.A{1}(3,2) = 1;
        DCM.A{1}(4,3) = 1;
        DCM.A{1}(6,4) = 1;
        DCM.A{1}(5,4) = 1;
        DCM.A{1}(7,5) = 1;
        DCM.A{1}(7,6) = 1;
        DCM.A{1}(6,1) = 1;
        DCM.A{1}(6,2) = 1;    
        
        DCM.A{2} = DCM.A{1}.';
        
        DCM.A{3} = zeros(Nareas,Nareas);
        Modulatory_self_connection = [];
        Modulatory_self_connection = ones(1, Nareas);
        DCM.A{3} = diag(Modulatory_self_connection);
        
    
        DCM.C = [1; 1; 0; 0; 0; 0; 0];
        
        %--------------------------------------------------------------------------
        % Between trial effects
        %--------------------------------------------------------------------------
%         DCM.xU.X = [0 1; 1 0];
%         DCM.xU.name = {'Hi vs Lo', 'Lo vs Hi'};
        
        %--------------------------------------------------------------------------
        % Invert
        %--------------------------------------------------------------------------
        DCM.name = 'DCM_CMC_M2';
        
        DCM      = spm_dcm_erp(DCM);   
    end
end
