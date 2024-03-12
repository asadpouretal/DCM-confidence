function plotAllNeuralCorrelations(significant_population_in_condition)
    % Iterate through each cell in the significant_population_in_condition array
    for i = 1:length(significant_population_in_condition)
        % Extract the structure from the current cell
        currentStruct = significant_population_in_condition{i};
        
        % Extract the necessary fields from the structure
        timePoints = currentStruct.CommonFeatures;
        regionNames = currentStruct.SourceNames;
        sourceNames = currentStruct.PopulationNames; 
        behaviorType = currentStruct.Behavior;
        conditionName = currentStruct.ConditionName;
        showLegend = 1;

        % Call the plotNeuralCorrelations function with the extracted data
        plotNeuralCorrelations(timePoints, regionNames, sourceNames, behaviorType, conditionName, showLegend);
    end
end
