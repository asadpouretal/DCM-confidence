function min_max = plot_DCM_scalp_map(DCM)
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
    title_fontweight = 'bold';      % 
    lable_fontsize = 30;            % main title for each row
    subtitle_fontsize = 20;         % subplot title font size
    column_title_position = [0 ...  % adjust annoation
        -0.4 0 0];
    column_xlabel_position = ...    % adjust annotion for subplot xlabel
        [0 -0.04 0 0];
    scale = DCM.xY.scale;
        % get spatial projector
        % -----------------------------------------------------------------
        try
            U = DCM.M.U';
        catch
            U = 1;
        end
        
        try
            pos = DCM.xY.coor2D;
        catch
            [xy, label]  = spm_eeg_project3D(DCM.M.dipfit.sens, DCM.xY.modality);
            [sel1, sel2] = spm_match_str(DCM.xY.name, label);
            pos = xy(:, sel2);
        end
        
        ns = 5; %number of time frames
        
        in           = [];
        in.type      = DCM.xY.modality;
        in.f         = gcf;
        in.noButtons = 1;
        in.cbar      = 0;
        in.plotpos   = 0;
        
        % plot data
        % -----------------------------------------------------------------
        whole_min_max = cell(1, nt);
        min_max = cell(1, nt);
        for i = 1:nt
            Yo  = (DCM.H{i} + DCM.R{i})*U;
            Yp  = DCM.H{i}*U;
            
            for j = 1:ns
                ind    = ((j-1)*floor(nb/ns)+1):j*floor(nb/ns);
                
                in.max = max(abs(mean(Yo(ind, :))));
                in.min = -in.max;
                whole_min_max{i}(:,j) = [in.max;in.min];
            end

            in.max = max(whole_min_max{i}(1,:));
            in.min = min(whole_min_max{i}(2,:));
            min_max{i} = [in.max; in.min];

            for j = 1 : ns
                ind    = ((j-1)*floor(nb/ns)+1):j*floor(nb/ns);
                in.ParentAxes = subtightplot(nt*2,ns,(i - 1)*2*ns + j, [], [], []);
                % set(in.ParentAxes,'color','w');
                spm_eeg_plotScalpData(mean(Yo(ind, :))', pos , DCM.xY.name, in);
                % title(sprintf('\n%.0f ms', mean(t(ind))), 'FontSize', subtitle_fontsize);

                if j == 3   % the middle panel
                    axes_position = get(in.ParentAxes, 'Position');
                    title_poision = axes_position - column_title_position;
                    titleHandles = annotation('textbox','String','Observed', ...
                        'Position', title_poision, ... 
                        'HorizontalAlignment', 'center','VerticalAlignment','bottom',...
                        'LineStyle','none','FitBoxToText','on', ...
                        'FontWeight',title_fontweight, ... % matches title property
                        'FontSize', lable_fontsize);   % matches title property
                end

                
                in.ParentAxes = subtightplot(nt*2,ns,(i - 1)*2*ns + ns + j, [], [], []);
                axes_position = get(in.ParentAxes, 'Position');
                xlabel_position = axes_position - column_xlabel_position;
                spm_eeg_plotScalpData(mean(Yp(ind, :))', pos, DCM.xY.name, in);
                xlabel(in.ParentAxes, sprintf('%.0f ms', mean(t(ind))), 'FontSize', subtitle_fontsize);
                xlabelHandles = annotation('textbox','String',sprintf('%.0f ms', mean(t(ind))), ...
                        'Position', xlabel_position, ... 
                        'HorizontalAlignment', 'center','VerticalAlignment','bottom',...
                        'LineStyle','none','FitBoxToText','on', ...
                        'FontWeight','normal', ... % matches title property
                        'FontSize', subtitle_fontsize);   % matches title property
                if j == 3   % the middle panel
                    
                    title_poision = axes_position - column_title_position;
                    titleHandles = annotation('textbox','String','Predicted', ...
                        'Position', title_poision, ... 
                        'HorizontalAlignment', 'center','VerticalAlignment','bottom',...
                        'LineStyle','none','FitBoxToText','on', ...
                        'FontWeight',title_fontweight, ... % matches title property
                        'FontSize', lable_fontsize);   % matches title property
                end                
            end
        end
        