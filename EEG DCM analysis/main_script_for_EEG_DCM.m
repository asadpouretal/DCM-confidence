clear; close all;
restoredefaultpath;

%% high vs low confidence EEG DCM analysis
import_data_before_DCM_for_high_vs_low; % prepare epoched ERP data for feeding DCM
DCM_ERP_high_vs_low_sustained_guassian_input;   %calculate DCMs for low and high confidence conditions with two models
BMS1_Group_Compare_DCMs_for_high_low;   % Bayesian model selection for low and high confidence conditions

% Parametric Empirical Bayes (BEB) for high and low confidence rating
% conditions
params = getParameters();
result_dir = fullfile(params.high_low_result_path, 'SPM Analyses', params.DCM_folder_name); % result folder for high and low confidence conditions
condition_names = params.high_low_condition_name;
PEB_calculation(result_dir, condition_names, params.highlow_winning_model_number);  % Parametric empricial Bayes analysis for extrinsic connections at group level

% estimated sources activity for high and low confidence conditions
population_voltage_sustained_input_for_separate_high_low

%% Fast and slow choice-based RT EEG DCM analysis
import_data_before_DCM_for_fast_slow_RT; % prepare epoched ERP data for feeding DCM
DCM_ERP_fast_vs_slow_sustained_gaussian_input; %calculate DCMs for fast and slow RTs conditions with two models
BMS1_Group_Compare_DCMs_for_fast_slow; % Bayesian model selection for fast and slow RTs conditions

% Parametric Empirical Bayes (BEB) for fast and slow choice-based RT
% conditions
params = getParameters();
result_dir = fullfile(params.fast_slow_result_path, 'SPM Analyses', params.DCM_folder_name); % result folder for fast and slow RT conditions
condition_names = params.fast_slow_condition_name;
PEB_calculation(result_dir, condition_names, params.fastslow_winning_model_number); % Parametric empricial Bayes analysis for extrinsic connections at group level

% estimated sources activity for fast and slow choice-based RT conditions
population_voltage_sustained_input_for_separate_fast_slow;

%% Trial-by-trial DCM analysis
DCM_ERP_highlow_sustained_guassian_input_trial_by_trial;     %calculate trial-by-trial DCMs for low and high confidence conditions with two models
DCM_ERP_fastslow_sustained_guassian_input_trial_by_trial;   %calculate trial-by-trial DCMs for fast and slow RTs conditions with two models

SVR_trial_DCM_analysis; % Support vector regression analysis to extract time points with correlation to behaviour

plot_trial_by_trial_neural_activity;    % Plot the results specifically for Figure 6 in the paper and last 4 figures in the supplementary information
