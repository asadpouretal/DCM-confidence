function params = getMRIParameters()
    % Define the subfolder identifier for BOLD fMRI data
    params.main_dir = 'U:\Data\Sabina''s Decision Making';
    params.spm_dir = 'C:\Toolbox\spm12';
    params.data_main_dir_pattern = fullfile(params.main_dir, 'sub-'); %Specify subjects data directory pattern
    params.niipattern = {'sub-*_run-01_bold.nii', 'sub-*_run-02_bold.nii'};
    params.total_subjects = 1; %23;
    params.cluster_centroids = {[743 907],[1021 1198], [924 1084], [719 935], [981 1160], [917 1086], [814 998], [1051 1167], [944 1157], [1106 1215], [676 830], [986 1161], [928 1150], [1102 1215], [1081 1214], [1045 1207], [745 927], [999 1142],...
    [1053 1204], [1033 1179], [1026 1161], [691 850], [1025 1182]};
    params.num_of_volumes = 771;
end
