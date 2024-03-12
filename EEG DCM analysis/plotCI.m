function [yMean, yCI95] = plotCI(x,y,alpha, color_of_line, lighter_color, linewidth, str, K_condition1, K_condition2)
% y:                                                % Experiments Dataset
% alpha:                                            % Confidence Interval percentage
% linewidth = 2;                                      % Line width of the mean line
% x = 1:1:size(y,2);                                  % Time vector
% str{1}                                            % legend for mean plot
% str{2}                                            % legend for CI 95
N = size(y,1);                                      % Number of ‘Experiments’ In Data Set
yMean = mean(y);                                    % Mean Of All Experiments At Each Value Of ‘x’
ySEM = std(y)/sqrt(N);                              % Compute ‘Standard Error Of The Mean’ Of All Experiments At Each Value Of ‘x’
CI = (100 - alpha) /200;
CI95 = tinv([CI (1 - CI)], N-1);                    % Calculate alpha% Probability Intervals Of t-Distribution
yCI95 = bsxfun(@times, ySEM, CI95(:));              % Calculate alpha% Confidence Intervals Of All Experiments At Each Value Of lxp


xconf = [x x(end:-1:1)] ;         
yconf = [yMean+yCI95(2,:) yMean(end:-1:1)+yCI95(1,:)];

p = fill(xconf,yconf,color_of_line, 'FaceAlpha',0.5);
p.FaceColor = lighter_color;      
p.EdgeColor = 'none';           

hold on
plot(x,yMean,'r', 'LineWidth',linewidth, 'DisplayName', str{1}, 'color', color_of_line)
% hold off

    % Get current y-axis limits after plotting
    yLimits = get(gca, 'YLim');

    % Perform non-parametric statistical analysis
    if ~isempty(K_condition1) && ~isempty(K_condition2)
        % Assuming K_condition1 and K_condition2 have the same dimensions as y
        for i = 1:length(x)
            % Perform Wilcoxon rank-sum test at each point in x
            [p, ~, ~] = ranksum(K_condition1(:, i), K_condition2(:, i));

            % If the difference is significant, annotate the plot
            if p < 0.05  % Use a significance level of 0.05 or adjust as needed
                hold on;
                % Place marker just above the x-axis
                ylim([(yLimits(1) - 0.06 * diff(yLimits)) yLimits(2)]);
                markerPosition = yLimits(1) - 0.02 * diff(yLimits); % 2% below the lower y-limit
                plot(x(i), markerPosition, 'k.', 'MarkerSize', 30);
            end
        end
    end

    % Finish plotting
    hold off;
end
