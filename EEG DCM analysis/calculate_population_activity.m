function [population_activity] = calculate_population_activity(DCM, condition_name)
% CALCULATE_POPULATION_ACTIVITY Compute the neural population activity.
% 
% INPUT:
% DCM - A structure containing dynamic causal modeling data.
%
% OUTPUT:
% population_activity - A structure containing calculated neural population activity.
%
% This function returns the neural population activity of an estimated DCM based on 
% the population model (default: CMC).

    % Extract neural activity and conductance
    [K, ns, nt, np] = cal_neural_activity(DCM); 

    % Load population names
    population_names = load_population_names();

    % Define indices
    pop_index = 1 : 2 : np;
    source_vector = 1 : ns;

    % Extract source names and time vector from DCM
    sources_name = DCM.Sname; 
    time_vector = DCM.xY.pst;

    % Compute source and population activities
    for i = source_vector
        for k = 1 : nt
            for population = 1 : length(pop_index)
                source_activity{i, population}(:, k) = K{k}(:, i + ns * (pop_index(population) - 1));
                population_name{i, population} = population_names{pop_index(population)};
            end       
        end
    end

    % Assign results to the output structure
    population_activity.t = time_vector;
    population_activity.source_activity = source_activity;
    population_activity.population_name = population_name(1, :);
    population_activity.sources_name = sources_name;
    population_activity.condition_name = condition_name;
end