function newDCM = get_trial_DCM_parameters(DCM, condition_name)
%get_trial_DCM_parameters assign DCM parameters based on
%scenario and condition
%   Detailed explanation goes here

params = getParameters();

A = [];
B = [];
C = [];


name = 'winning_trial_DCM_CMC';

switch lower(condition_name) %make it case insensitive. all lower cases
    case 'low confidence'
        Lpos  = params.highlow_Lpos;
        Sname = params.highlow_Sourcename;
        Nareas = size(Lpos,2);
        A{1} = zeros(Nareas,Nareas);
        A{2} = zeros(Nareas, Nareas);
        A{1}(2,1) = 1;
        A{1}(3,1) = 1;
        A{1}(3,2) = 1;
        A{1}(4,3) = 1;
        A{1}(6,4) = 1;
        A{1}(5,4) = 1;
        A{1}(7,5) = 1;
        A{1}(7,6) = 1;
        
        A{2} = A{1}.';

        C = [1; 1; 0; 0; 0; 0; 0];        

    case 'high confidence'
        Lpos  = params.highlow_Lpos;
        Sname = params.highlow_Sourcename;
        Nareas = size(Lpos,2);
        A{1} = zeros(Nareas,Nareas);
        A{2} = zeros(Nareas, Nareas);
        A{1}(2,1) = 1;
        A{1}(3,1) = 1;
        A{1}(3,2) = 1;
        A{1}(4,3) = 1;
        A{1}(6,4) = 1;
        A{1}(5,4) = 1;
        A{1}(7,5) = 1;
        A{1}(7,6) = 1;
        
        A{2} = A{1}.';

        C = [1; 1; 0; 0; 0; 0; 0];

    case 'fast rts'
        Lpos  = [[18; -55; 59] [54; -55; 35] [-6; -67; 35] [-39; -13; 56] [-3; -4; 56]];
        Sname = {'right Superior Parietal Lobule', 'right Supramarginal Gyrus',...
            'left Precuneus', 'left Precentral Gyrus', 'left Medial Frontal Gyrus'};
        Nareas = size(Lpos,2);

        A{1} = zeros(Nareas,Nareas);
        A{2} = zeros(Nareas, Nareas);
        A{1}(2,1) = 1;
        A{1}(3,1) = 1;
        A{1}(4,3) = 1;
        A{1}(5,4) = 1;
    
        
        A{2} = A{1}.';

        C = [1; 0; 0; 0; 0];

    case 'slow rts'
        Lpos  = params.fastslow_Lpos;
        Sname = params.fastslow_Sourcename;
        Nareas = size(Lpos,2);

        A{1} = zeros(Nareas,Nareas);
        A{2} = zeros(Nareas, Nareas);
        A{1}(2,1) = 1;
        A{1}(3,1) = 1;
        A{1}(4,3) = 1;
        A{1}(5,4) = 1;
    
        
        A{2} = A{1}.';

        C = [1; 0; 0; 0; 0];

    case 'stimulation'

        Lpos  = [[18; -61; 62] [39; -49; 56] [6; -61; 44] [-30; -73; 38] [-3; -46; 41]...
            [-45;-25; 20] [54; -31; 17] [24; 62; 14]];
        Sname = {'right Superior Parietal Lobule', 'right Inferior Parietal Lobule',...
            'right Precuneus', 'left Precuneus', 'left Cingulate Gyrus',...
            'left Insula' 'right Insula', 'right Superior Frontal Gyrus'};

        Nareas = size(Lpos,2);
        A{1} = zeros(Nareas,Nareas);
        A{2} = zeros(Nareas, Nareas);
        A{1}(1,2) = 1;
        A{1}(3,1) = 1;
        A{1}(3,2) = 1;
        A{1}(4,3) = 1;
        A{1}(7,3) = 1;
        A{1}(5,4) = 1;
        A{1}(6,4) = 1;
        A{1}(6,5) = 1;
        A{1}(8,5) = 1;
        A{1}(6,7) = 1;
        A{1}(8,7) = 1;
        
        A{2} = A{1}.';

        C = [1; 1; 0; 0; 0; 0; 0; 0];

    case 'rating'
        Lpos  = [[18; -61; 62] [39; -49; 56] [6; -61; 44] [-30; -73; 38] [-3; -46; 41]...
            [-45;-25; 20] [54; -31; 17] [24; 62; 14]];
        Sname = {'right Superior Parietal Lobule', 'right Inferior Parietal Lobule',...
            'right Precuneus', 'left Precuneus', 'left Cingulate Gyrus',...
            'left Insula' 'right Insula', 'right Superior Frontal Gyrus'};
        Nareas = size(Lpos,2);
        A{1} = zeros(Nareas,Nareas);
        A{2} = zeros(Nareas, Nareas);
        A{1}(1,2) = 1;
        A{1}(3,1) = 1;
        A{1}(3,2) = 1;
        A{1}(4,3) = 1;
        A{1}(7,3) = 1;
        A{1}(5,4) = 1;
        A{1}(6,4) = 1;
        A{1}(6,5) = 1;
        A{1}(8,5) = 1;
        A{1}(6,7) = 1;
        A{1}(8,7) = 1;
        
        A{2} = A{1}.';

        C = [1; 1; 0; 0; 0; 0; 0; 0];
end

A{3} = zeros(Nareas,Nareas);
Modulatory_self_connection = [];
Modulatory_self_connection = ones(1, Nareas);
A{3} = diag(Modulatory_self_connection);

newDCM = DCM;

newDCM.A = A;
newDCM.C = C;
newDCM.name = name;
newDCM.Lpos = Lpos;
newDCM.Sname = Sname;


end