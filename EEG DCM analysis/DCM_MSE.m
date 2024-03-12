function final_err = DCM_MSE(DCM)
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

        try
            U = DCM.M.U';
        catch
            U = 1;
        end
        
        % Calculate Mean Squarred Error
        % -----------------------------------------------------------------
        
        for i = 1:nt
            Yo  = (DCM.H{i} + DCM.R{i})*U;
            Yp  = DCM.H{i}*U;
            
            err(i) = immse(Yp, Yo);
        end
        final_err = mean(err);
end
        