close all; clearvars;

% Get the full path of the currently executing script
scriptFullPath = mfilename('fullpath');
% Extract the directory of the script
scriptDir = fileparts(scriptFullPath);

addtional_files_path = fullfile(scriptDir, 'additional_files');
fMRI_analysis_path = fullfile(scriptDir,'fMRI analysis');
EEG_DCM_analysis_path = fullfile(scriptDir,'EEG DCM analysis');

addpath(addtional_files_path, fMRI_analysis_path, EEG_DCM_analysis_path);
%% extract events for each condition
event_extraction_high_low   % extract for high and low confidence condtions
event_extraction_for_fast_vs_slow   % extarct for fast and slow RTs

%% extract and preprocess fMRI 
[niifiles, structural_niifiles] = preprocess_fMRI();

%% contrast and statistical analysis
run_statistics_for_high_vs_low_confidence;  % contrast and statistical analysis for high and low confidence conditions
run_statistics_for_fast_vs_slow;    % contrast and statistical analysis for fast and slow RT conditions