function [K, ns, nt, np] = cal_neural_activity(DCM)
%cal_neural_activity Calculate neural activity matrix in the source space (K)
%   variables extracted from the estimated DCM

        % trial data
        %--------------------------------------------------------------------------
        xY  = DCM.xY;                   % data
        x = DCM.x;                      % conditional responses (x) (all states)
        M = DCM.M;                      % model specification
        Qg = DCM.Eg;                    % conditional expectation
        nt  = length(xY.y);             % Nr trial types
        Nt      = length(xY.y);         % number of trials
        Ns  = size(xY.y{1},1);          % number of time bins
        Nr      = size(DCM.C,1);        % number of sources
        ne  = size(xY.y{1},2);          % Nr electrodes
        nb  = size(xY.y{1},1);          % Nr time bins
        t   = xY.pst;                   % PST
        
        
        
        % post inversion parameters
        %--------------------------------------------------------------------------
        nu  = length(DCM.B);          % Nr inputs
        nc  = size(DCM.H{1},2);       % Nr modes
        ns  = size(DCM.A{1},1);       % Nr of sources
        
        
        % Calculate the voltage of all the populations
        %--------------------------------------------------------------------------
        try
            j = find(kron(Qg.J,ones(1,Nr)));    % Indices of contributing states
        catch
            j = find(spm_cat(Qg.J));
        end
        
        x0  = ones(Ns,1)*spm_vec(M.x)';         % expansion point for states
        
        for i = 1:Nt
            K{i} = x{i} - x0;                   % centre on expansion point
        %     y{i} = M.R*K{i}*L'*M.U;             % prediction (sensor space)
        %     r{i} = M.R*xY.y{i}*M.U - y{i};      % residuals  (sensor space)
            K_contributing{i} = K{i}(:,j);                   % Depolarization in sources
        end
        np  = size(K{1},2)/ns;    % Nr of population per source
end