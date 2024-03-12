function best_DCM = find_best_participant(GCM_fullname, winning_model_number, index_of_winning_subjects)
    
%     GCM_fullname = {'U:\Data\Sabina''s Decision Making\DCM Models\Results of Fast vs Slow\SPM Analyses\DCM Models with sustained gaussian input\BMS_first_level_analysis_Fast.mat',...
%         'U:\Data\Sabina''s Decision Making\DCM Models\Results of Fast vs Slow\SPM Analyses\DCM Models with sustained gaussian input\BMS_first_level_analysis_Slow.mat',...
%         'U:\Data\Sabina''s Decision Making\DCM Models\Results of Rating Phase\SPM Analyses\Inference\RFX\GCM_Phasing_Stimulation_Subejcts.mat'};
    save_flag = 0;
    % condition_number = 1;
    load(GCM_fullname);
    GCM = data.GCM(index_of_winning_subjects,:);
    subject_actual_numbers = data.included_subject_numbers;
    population_number = [1 3 5 7];   % vector of neural populations to draw
    string_to_find = 'sub-';    % string to find the actual subject number


    
    for DCM_number = 1 : length(GCM(:,winning_model_number))
        load(GCM{DCM_number,winning_model_number});
        subject_MSE(DCM_number) = DCM_MSE(DCM);
    end
    [minimum, best_DCM_index] = min(subject_MSE);
    best_DCM = subject_actual_numbers(index_of_winning_subjects(best_DCM_index));

end