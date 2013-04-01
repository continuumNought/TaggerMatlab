%% Community tagging - folksonomy for event rich scientific data
%
% This test script illustrates the community tagging of event data
% Before running this script, use the file menu to set the MATLAB path to
% include this directory and its subdirectories.
% 

%% Add the appropriate java path (to use either a .jar file or a java archive)
configPath = which('cTagger.m');
if isempty(configPath)
    error('Add ctagger and all subdirectories to MATLAB path');
end
javaPath = strrep(configPath, 'cTagger.m','');
%javaPath = [javaPath filesep 'jars' filesep 'ctagger.jar'];  % With jar
javaPath = [javaPath filesep 'java' filesep 'bin']; % Java source and bin
warning off all;
try
    javaaddpath(javaPath);
catch mex 
end
warning on all;

%% Load and validate
HEDXML = fileread('HEDSpecification1.3.xml');
HEDSch = fileread('HEDSchema.xsd');
edu.utsa.tagger.database.XMLGenerator.validateSchemaString(HEDXML, HEDSch);
%% Read HED specification (this is a tag hierarchy to start with)
HEDXML = fileread('HED Specification 1.21.xml');

%% Example 1a: Event list has no initial no tagging (use base HED)
eventList = '1,Trigger,,;2,Button Press,code 2;3,RT,code 3,'; 
[tagList1, newHEDXML1] = createTags(eventList, HEDXML);  

%% Example 1: Event list has no initial no tagging (use base HED)
eventList = '1,Trigger,code 1;2,Button Press,code 2;3,RT,code 3'; 
[tagList1, newHEDXML1] = createTags(eventList, HEDXML);  


%% Write the potentially modified XML hierarchy to a file for future reference
fid = fopen('newHEDXML1Rewrite.xml', 'w', 'n', 'UTF-8');
fwrite(fid, newHEDXML1, 'char')
fclose(fid);

%%
fid = fopen('newHEDXML1Rewrite.xml', 'w', 'n', 'UTF-8');
fwrite(fid, h3, 'char')
fclose(fid);

%% Example 2: event list with some pretagging, using new hiearchy
baseList = ['1,Trigger,code 1,' ...
              '/Time-Locked Event/Stimulus/Visual/Shape/Ellipse/Circle,' ...
              '/Time-Locked Event/Stimulus/Visual/Fixation Point,' ...
              '/Time-Locked Event/Stimulus/Visual/Uniform Color/Black;' ...
              '2,Button Press,code 2;3,RT,code 3'];
[tagList2, newHEDXML2] = createTags(eventList, newHEDXML1, 'code', true, baseList);   %#ok<ASGLU>
