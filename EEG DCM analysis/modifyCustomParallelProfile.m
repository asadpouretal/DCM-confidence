function modifyCustomParallelProfile(profileName, numWorkers, matlabRoot, jobStorageLocation)
    % Get the custom profile
    c = parcluster(profileName);

    if ~isfolder(jobStorageLocation)
        mkdir(jobStorageLocation);
    end
    
    % Modify the properties
    c.NumWorkers = numWorkers;
    c.ClusterMatlabRoot = matlabRoot;
    switch filesep
        case '/'
            c.OperatingSystem = 'unix'; % or 'windows', based on your system
        case '\'
            c.OperatingSystem = 'windows'; % or 'windows', based on your system
    end
    c.JobStorageLocation = jobStorageLocation;
    c.HasSharedFilesystem = true;
    
    % Save the modified profile
    c.saveProfile();
    fprintf('Profile named "%s" has been modified.\n', profileName);
end