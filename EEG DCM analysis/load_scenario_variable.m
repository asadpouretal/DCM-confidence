function [variables] = load_scenario_variable(scenario)
%load_scenario_variable load main variables of each three scanrios
%   this code loads GCM and BMS files as well as other variables as a structure for each
%   scenario (stimulation vs rating phase, high vs low confidence, and fast vs. slow responses)
params = getParameters();

switch lower(scenario)
    case 'fastslow'
        variables.GCM_fullname = {fullfile(params.fast_slow_result_path, 'SPM Analyses', params.DCM_folder_name, ['BMS_first_level_analysis_' params.fast_slow_condition_name{1} '.mat']),...
            fullfile(params.fast_slow_result_path, 'SPM Analyses', params.DCM_folder_name, ['BMS_first_level_analysis_' params.fast_slow_condition_name{2} '.mat'])};
        variables.BMS_fullfile = {fullfile(params.fast_slow_result_path, 'SPM Analyses', params.DCM_folder_name, params.inference_folder_pattern, params.fast_slow_condition_name{1}, params.inference_method, 'BMS.mat'),...
            fullfile(params.fast_slow_result_path, 'SPM Analyses', params.DCM_folder_name, params.inference_folder_pattern, params.fast_slow_condition_name{2}, params.inference_method, 'BMS.mat')};
        variables.winning_model_number = params.fastslow_winning_model_number;
        variables.color_of_line = {[0.4667    0.6745    0.1882], [0.929411764705882	0.694117647058824	0.125490196078431]};
        variables.lighter_color_of_line = {variables.color_of_line{1} * 1.4 , [0.929411764705882	0.823529411764706	0.576470588235294]};
    
    case 'highlow'
        variables.GCM_fullname = {fullfile(params.high_low_result_path, 'SPM Analyses', params.DCM_folder_name, ['BMS_first_level_analysis_' params.high_low_condition_name{1} '.mat']),...
            fullfile(params.high_low_result_path, 'SPM Analyses', params.DCM_folder_name, ['BMS_first_level_analysis_' params.high_low_condition_name{2} '.mat'])};
        variables.BMS_fullfile = {fullfile(params.high_low_result_path, 'SPM Analyses', params.DCM_folder_name, params.inference_folder_pattern, params.high_low_condition_name{1}, params.inference_method, 'BMS.mat'),...
            fullfile(params.high_low_result_path, 'SPM Analyses', params.DCM_folder_name, params.inference_folder_pattern, params.high_low_condition_name{2}, params.inference_method, 'BMS.mat')};
        variables.winning_model_number = params.highlow_winning_model_number;
        variables.color_of_line = {[0 0 0], [0.890196078431373	0.0784313725490196	0.0784313725490196]};    % High: Black, Low: Red
        variables.lighter_color_of_line = {[0.8	0.8	0.8] , [0.921568627450980	0.443137254901961	0.443137254901961]};

    case 'stimrating'
        variables.GCM_fullname = {'U:\Data\Sabina''s Decision Making\DCM Models\Results of Rating Phase\SPM Analyses\DCM Models with sustained gaussian input\BMS_first_level_analysis_Stimulation.mat',...
            'U:\Data\Sabina''s Decision Making\DCM Models\Results of Rating Phase\SPM Analyses\DCM Models with sustained gaussian input\BMS_first_level_analysis_Rating.mat'};
        variables.BMS_fullfile = {'U:\Data\Sabina''s Decision Making\DCM Models\Results of Rating Phase\SPM Analyses\DCM Models with sustained gaussian input\Inference for different inputs\Stimulation\RFX\BMS.mat',...
            'U:\Data\Sabina''s Decision Making\DCM Models\Results of Rating Phase\SPM Analyses\DCM Models with sustained gaussian input\Inference for different inputs\Rating\RFX\BMS.mat'};
        variables.winning_model_number = [3 3];
        variables.color_of_line = {[0.392156862745098	0.807843137254902	0.960784313725490], [0.419607843137255	0.298039215686275	0.603921568627451]};    % Stim - Rating: sky Blue - purple
        variables.lighter_color_of_line = {[0.670588235294118	0.882352941176471	0.960784313725490] , [0.654901960784314	0.607843137254902	0.729411764705882]};

end