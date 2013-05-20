%% Wet up the path to EEGLAB. Comment this section out if not using EEGLAB
EEGLABPATH = 'G:\CommunityTags\TaggerMatlab\eeglab11_0_4_3b';
wPath = which('eeglab.m');
if isempty(wPath) && isdir(EEGLABPATH)
    fprintf('Adding default EEGLAB path %s\n', EEGLABPATH);   
    addpath(genpath(EEGLABPATH));
elseif isempty(wPath)
    warning('setup:NoEEGLAB', ...
        ['Edit setup.m so that EEGLABPath is the full pathname ' ...
         'of directory containing EEGLAB if you want to use EEGLAB']);
end
%% Set up the paths
% Run from ctagger directory or have ctagger directory in your path
configPath = which('eegplugin_ctagger.m');
if isempty(configPath)
    error('Cannot configure: change to ctagger directory');
end
dirPath = strrep(configPath, [filesep 'eegplugin_ctagger.m'],'');
addpath(genpath(dirPath));

%% Now add java jar paths
jarPath = [dirPath filesep 'jars' filesep];  % With jar
warning off all;
try
    javaaddpath([jarPath 'ctagger.jar']);
    javaaddpath([jarPath 'jackson.jar']);
    javaaddpath([jarPath 'postgresql-9.2-1002.jdbc4.jar']);
catch mex 
end
warning on all;