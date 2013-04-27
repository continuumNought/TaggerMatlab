function test_suite = test_showDialog%#ok<STOUT>
initTestSuite;

function values = setup %#ok<DEFNU>
values.EEGLAB = 'EEGEpoch.mat';
values.hedfile = 'HEDSpecification1.3.xml';
values.eventsText = ['1,Trigger,code 1,' ...
              '/Time-Locked Event/Stimulus/Visual/Shape/Ellipse/Circle,' ...
              '/Time-Locked Event/Stimulus/Visual/Fixation Point,' ...
              '/Time-Locked Event/Stimulus/Visual/Uniform Color/Black;' ...
              '2,Button Press,code 2;3,RT,code 3'];
values.eventsJson = ['[{"code": "1","label": "RT","description": "RT","tags": [' ...
		 '"/Time-Locked Event/Stimulus/Visual/Shape/Ellipse/Circle",' ...
		 '"/Time-Locked Event/Stimulus/Visual/Fixation Point",' ...
		'"/Time-Locked Event/Stimulus/Visual/Uniform Color/Black"]}]'];
    
function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test


function testShowDialogJText(values)  %#ok<DEFNU>
% Unit test for edu.utsa.tagger.controller.Controller.showDialog static method 
fprintf('\nUnit tests for edu.utsa.tagger.controller.Controller.showDialog for text input\n');
HEDXML = fileread(values.hedfile);
fprintf('It should work when some events have tags and some don''t\n');
controller1 = char(edu.utsa.tagger.controller.Controller.showDialog(...
    HEDXML, values.eventsText, false));
newHed1 = strtrim(char(controller1(1, :)));
newEvents1 = strtrim(char(controller1(2, :)));
fprintf('The output should work again in showDialog\n');
controller2 = char(edu.utsa.tagger.controller.Controller.showDialog(...
                      newHed1, newEvents1, false));
fprintf('The output should not change if cancelled\n');
newHed2 = strtrim(char(controller2(1, :)));
newEvents2 = strtrim(char(controller2(2, :)));
fprintf('----Be sure to press cancel when GUI comes up-----\n');
controller3 = char(edu.utsa.tagger.controller.Controller.showDialog(...
                      newHed2, newEvents2, false));
newHed3 = strtrim(char(controller3(1, :)));
newEvents3 = strtrim(char(controller3(2, :)));
assertTrue(strcmpi(newHed2, newHed3));
assertTrue(strcmpi(newEvents2, newEvents3));

fprintf('It should work when there are no events\n');
fprintf('----Don''t make changes --- just submit-----\n');
controller4 = char(edu.utsa.tagger.controller.Controller.showDialog(HEDXML, '', false));
newEvents4 = strtrim(char(controller4(2, :)));
assertTrue(isempty(newEvents4));

fprintf('It should allow adding events\n');
fprintf('----Be sure to add and tag at least one event -----\n');
controller5 = char(edu.utsa.tagger.controller.Controller.showDialog(HEDXML, '', false));
newEvents5 = strtrim(char(controller5(2, :)));
assertTrue(~isempty(newEvents5));

