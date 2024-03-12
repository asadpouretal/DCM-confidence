function K_in_trial = calculateKInTrial(source_vector, nt, K, ns, pop_index)
    % This function calculates the K_in_trial cell array based on the provided parameters.

    % Initialize K_in_trial as a cell array
    K_in_trial = cell(nt, max(source_vector), max(pop_index));

    % Loop over each source number, trial, subject, and population
    for source_number = source_vector
        for trial_number = 1:nt
            for subjects = 1:size(K, 2)
                for population = pop_index
                    K_in_trial{trial_number, source_number, population}(subjects, :) = ...
                        K{trial_number, subjects}(:, source_number + ns * (population - 1))';
                end
            end
        end
    end
end
