function [subFolderNames] = extract_subfolder(topLevelFolder)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% Get a list of all files and folders in this folder.
files = dir(topLevelFolder);
% Get a logical vector that tells which is a directory.
dirFlags = [files.isdir];
% Extract only those that are directories.
subFolders = files(dirFlags); % A structure with extra info.
% Get only the folder names into a cell array.
subFolderNames = {subFolders(3:end).name}'; % Start at 3 to skip . and ..
end