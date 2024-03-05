close all; clearvars;

%% extract events for each condition
event_extraction_high_low   % extract for high and low confidence condtions
event_extraction_for_fast_vs_slow   % extarct for fast and slow RTs

%% extract and preprocess fMRI 
[niifiles, structural_niifiles] = preprocess_fMRI();

%% contrast and statistical analysis
run_statistics_for_high_vs_low_confidence;  % contrast and statistical analysis for high and low confidence conditions
run_statistics_for_fast_vs_slow;    % contrast and statistical analysis for fast and slow RT conditions