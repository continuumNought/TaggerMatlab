%% Community tagging - folksonomy for event rich scientific data
%
% This test script illustrates the community tagging of event data
% Before running this script, use the file menu to set the MATLAB path to
% include this directory and its subdirectories.
% 

%% Add the appropriate java path (to use either a .jar file or a java archive)
configPath = which('ctagger.m');
if isempty(configPath)
    error('Add ctagger and all subdirectories to MATLAB path');
end
javaPath = strrep(configPath, 'ctagger.m','');
%javaPath = [javaPath filesep 'jars' filesep 'ctaggergson.jar'];  % With jar
%javaPath = [javaPath filesep 'jars' filesep 'ctaggerJSON.jar'];  % With jar
javaPath = [javaPath filesep 'java' filesep 'bin']; % Java source and bin
%javaPath = [javaPath 'G:\\CommunityTagging\\Tagging12\\eclipseWorkspace\\gsonRecompile\\bin'];
%javaPath = [javaPath filesep 'java' filesep 'lib' filesep 'gson-2.2.2jar']; % Java source and bin
warning off all;
try
    javaaddpath(javaPath);
catch mex 
end
% warning on all;
% javaPath1 = [javaPath filesep 'java' filesep 'bin']; % Java source and bin
% javaPath2 = [javaPath filesep 'java' filesep 'jars']; 
% warning off all;
% try
%     javaaddpath(javaPath1, JavaPath2);
% catch mex 
% end
warning on all;

%%
g = com.google.gson.Gson();

%%
m = edu.utsa.tagger.model.Model();
%% Read HED specification (this is a tag hierarchy to start with)
HEDXML = fileread('HED Specification 1.21.xml');

%%
HEDXMLSmall = fileread('HEDSmall.xml');
%% Example 2:  Extract from an EEG structure
load EEGEpoch.mat;

%%
eTags = getEEGTags(EEGEpoch);

%%
eTags.hedXML = HEDXML;
%%
jTags = savejson('', eTags);
%%
jTagsOut = ctagger(jTags);  
%% Write the potentially modified XML hierarchy to a file for future reference
fid = fopen('newHEDXML1Rewrite.xml', 'w', 'n', 'UTF-8');
fwrite(fid, newHEDXML1, 'char')
fclose(fid);

%% Example 2: event list with some pretagging, using new hiearchy
baseList = ['1,Trigger,code 1,' ...
              '/Time-Locked Event/Stimulus/Visual/Shape/Ellipse/Circle,' ...
              '/Time-Locked Event/Stimulus/Visual/Fixation Point,' ...
              '/Time-Locked Event/Stimulus/Visual/Uniform Color/Black;' ...
              '2,Button Press,code 2;3,RT,code 3'];
[tagList2, newHEDXML2] = ctagger(eventList, newHEDXML1, 'code', true, baseList);   %#ok<ASGLU>
