%% Community tagging - folksonomy for event rich scientific data
%
% This test script illustrates the community tagging of event data
% Before running this script, use the file menu to set the MATLAB path to
% include this directory and its subdirectories.
% 

%% Add the appropriate java path (to use either a .jar file or a java archive)
setupCTagger;

%% Read HED specification (this is a tag hierarchy to start with)
HEDXML = fileread('HED Specification 1.22.xml');


%% Work with text events first
events = ['1,Trigger,code 1,' ...
              '/Time-Locked Event/Stimulus/Visual/Shape/Ellipse/Circle,' ...
              '/Time-Locked Event/Stimulus/Visual/Fixation Point,' ...
              '/Time-Locked Event/Stimulus/Visual/Uniform Color/Black;' ...
              '2,Button Press,code 2;3,RT,code 3'];

%% Call the GUI
controller1 = char(edu.utsa.tagger.controller.Controller.showDialog(HEDXML, events));

%% Evaluate
newHed1 = strtrim(char(controller1(1, :)));
newEvents1 = strtrim(char(controller1(2, :)));

%% Call the GUI again with the previous steps
controller2 = char(edu.utsa.tagger.controller.Controller.showDialog(...
                      newHed1, newEvents1));

%%
newHed2 = strtrim(char(controller2(1, :)));
newEvents2 = strtrim(char(controller2(2, :)));

%%
controller3 = char(edu.utsa.tagger.controller.Controller.showDialog(...
                      newHed2, newEvents2));
%% 
eventsJson = ['[{"code": "1","label": "RT","description": "RT","tags": [' ...
		 '"/Time-Locked Event/Stimulus/Visual/Shape/Ellipse/Circle",' ...
		 '"/Time-Locked Event/Stimulus/Visual/Fixation Point",' ...
		'"/Time-Locked Event/Stimulus/Visual/Uniform Color/Black"]}]'];
 %% 
controller4 = char(edu.utsa.tagger.controller.Controller.showDialog(HEDXML, eventsJson, true));

%%
newHed4 = strtrim(char(controller4(1, :)));
newEvents4 = strtrim(char(controller4(2, :)));

%%
controller5 = char(edu.utsa.tagger.controller.Controller.showDialog(newHed4, newEvents4, true));

%%
%% Read HED specification (this is a tag hierarchy to start with)
HEDXML = fileread('HED Specification 1.22.xml');
Schema = fileread('HEDSchema.xsd');

%% Check XML
isValid = edu.utsa.tagger.database.XMLGenerator.checkXML(HEDXML);

%%
nedNew = edu.utsa.tagger.database.XMLGenerator.updateXML(HEDXML, {'/a/b', '/c/def'});


%%
isValid1 = edu.utsa.tagger.database.XMLGenerator.checkXML(nedNew);

%%
ned3 = '<hed><node><name>Dot pattern expectancy task</name></node>';
isValid2 = edu.utsa.tagger.database.XMLGenerator.checkXML(ned3);
%%
newHed1 = edu.utsa.tagger.database.XMLGenerator.mergeXML(HEDXML, HEDXML);
%%
isvalid3 = edu.utsa.tagger.database.XMLGenerator.checkXML(newHed1);


newTags = eventTags(char(nedNew), '');

%%
newTags1 = cTagger.tagThis(newTags);

%%
edu.utsa.tagger.database.XMLGenerator.validateSchemaString(HEDXML, Schema);

%%