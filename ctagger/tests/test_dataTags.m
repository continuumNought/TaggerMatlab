function test_suite = test_dataTags %#ok<STOUT>
initTestSuite;

function values = setup %#ok<DEFNU>
fields = {'type', 'type', 'parameter'}; 
types = {'RT', 'Trigger', 'Missed'};
eStruct = struct('field', 'type', 'xml', 'abc', 'events', 'def');
tags = {'/Time-Locked Event/Stimulus/Visual/Shape/Ellipse/Circle', ...
        '/Time-Locked Event/Stimulus/Visual/Fixation Point', ...
        '/Time-Locked Event/Stimulus/Visual/Uniform Color/Black'};
sE = struct('label', types, 'description', types, 'tags', '');
sE(1).tags = tags;
eStruct.field = 'type';
eStruct.xml = fileread('HEDSpecification1.3.xml');
eStruct.events = sE;
values.eJSON1 = savejson('', eStruct);
values.eStruct1 = eStruct;
values.eventList1 = 'Trigger,code 1,/my/tag1, /my/tag2;Trigger2,t2,';
values.baseList1 = 'Trigger,code 1,/my/tag1/a, /my/tag3';
values.eventList2 = 'Trigger,code 2,/my/tag1, /my/tag2';
values.baseList2 = 'Trigger,code 3,/my/tag3, /my/tag4';
values.eventList3 = 'RT,code 4,/my/tag1, /my/tag2';
values.baseList3 = 'Trigger,code 1,/my/tag4, /my/tag2; RT,code 4,/my/tag1, /my/tag2';

values.emptyEvent = '';
values.eventMissingFields = struct('label', types);
values.eventEmptyTags = struct('label', types, 'description', types, 'tags', '');
values.oneEvent = struct('label', 'abc type', 'description', '', 'tags', '/a/b');
values.noTagsFile = 'EEGEpoch.mat';
values.oneTagsFile = 'etags.mat';
values.otherTagsFile = 'eTagsOther.mat';

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test



function testValid(values) %#ok<DEFNU>
% Unit test for dataTags constructor valid JSON
fprintf('\nUnit tests for dataTags valid JSON constructor\n');

fprintf('It should create a valid dataTags object for a valid JSON events string\n');
[field1, xml1, events1] = eventTags.split(values.eJSON1, true);
assertTrue(strcmpi(field1, 'type'));
obj1 = dataTags(xml1);
assertTrue(isvalid(obj1));
fprintf('It should have the right number of events\n');
for k = 1:length(events1)
    obj1.addEvent(field1, events1{k}, 'Merge');
end
events = obj1.getEvents();
assertEqual(length(events), 3);
fprintf('It should create a valid object for a valid text string\n');
testString = ['type;' values.eStruct1.xml ';' values.eventList1];
[field2, xml2, events2] = dataTags.split(testString, false);
assertTrue(strcmpi(field2, 'type'));
obj2 = dataTags(xml2, events2);
assertTrue(isvalid(obj2));
fprintf('It should have the right number of events\n');
events = obj2.getEvents();
assertEqual(length(events), 2);

function testEmptyOrInvalid(values) %#ok<INUSD,DEFNU>
% Unit test for dataTags constructor empty or invalid
fprintf('\nUnit tests for dataTags empty or invalid JSON\n');

fprintf('It should throw  are no arguments\n');
f = @() dataTags();
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should output a warning if an empty string is used ---WARNING\n');
obj1 = dataTags('', '');
assertTrue(isvalid(obj1));
fprintf('---the resulting structure should have the right fields\n');
eStruct1 = obj1.getStruct();
assertTrue(isstruct(eStruct1));
assertEqual(length(fieldnames(eStruct1)), 3);
assertElementsAlmostEqual(sum(isfield(eStruct1, {'field', 'xml', 'events'})), 3);
assertTrue(~isempty(eStruct1.xml));
assertTrue(isempty(eStruct1.events));


function testMergeXml(values) %#ok<INUSD,DEFNU>
% Unit test for dataTags mergeXml static method
fprintf('\nUnit tests for mergeXml static method of dataTags\n');

fprintf('It should merge XML when both tag sets are empty\n');
obj1 = dataTags('', '');
obj1.mergeXml('');
xml1 = obj1.getXml;
assertTrue(~isempty(xml1));
% obj.mergeHedXML('');
% assertTrue(isempty(obj.getHedXML));
% fprintf('It should merge Hed XML when new set is not empty\n');
% obj.mergeHedXML(values.HEDXML);
% assertTrue(strcmp(values.HEDXML, obj.getHedXML));
% fprintf('It should merge HedXML when both sets are not empty\n');
% obj.mergeHedXML(values.HEDXML);
% assertTrue(strcmp(values.HEDXML, obj.getHedXML));

function testMergedataTags(values) %#ok<DEFNU>
% Unit test for dataTags mergedataTags method
fprintf('\nUnit tests for mergedataTags method of dataTags\n');

fprintf('It should merge correctly when code match is specified with matches found\n');
[f1, h1, e1] = dataTags.split([';;' values.eventList1], false);
[f1a, h1a, b1] = dataTags.split([';;' values.baseList1], false);
assertTrue(isempty(f1));
assertTrue(isempty(f1a));
e1 = dataTags(h1, e1);
b1 = dataTags(h1a, b1);
e1.mergedataTags(b1, 'OnlyTags');
eEvents = e1.getEvents();
assertEqual(length(eEvents), 2);
event1 = e1.getEvent('Trigger');
assertTrue(~isempty(event1));
fprintf('It should correctly merge tags when event codes match\n');
assertEqual(length(event1.tags), 3);
fprintf('It should have not merge events when argument is empty\n');
e1.mergedataTags('', 'OnlyTags');
eEvents = e1.getEvents();
assertEqual(length(eEvents), 2);
e1.mergedataTags('', 'Merge');
eEvents = e1.getEvents();
assertEqual(length(eEvents), 2);
fprintf('It should not include extra events if OnlyTags is true\n');
[f3, h3, b3] = dataTags.split([';;' values.baseList3], false);
assertTrue(isempty(f3));
b3 = dataTags(h3, b3);
e1.mergedataTags(b3, 'OnlyTags');
eEvents = e1.getEvents();
assertEqual(length(eEvents), 2);
fprintf('It should include extra events if OnlyTags is false\n');
e1.mergedataTags(b3, 'Merge');
eEvents = e1.getEvents();
assertEqual(length(eEvents), 3);

fprintf('It should work when PreservePrefix is true\n');
[f2, h2, e2] = dataTags.split([';;' values.eventList1], false);
assertTrue(isempty(f2));
eT2 = dataTags(h2, e2, 'PreservePrefix', true);
eT2.mergedataTags(b1, 'OnlyTags');
eEvents = eT2.getEvents();
assertEqual(length(eEvents), 2);
event2 = eT2.getEvent('Trigger');
assertTrue(~isempty(event2));
fprintf('It should correctly merge tags when event codes match\n');
assertEqual(length(event2.tags), 4);



function testGetText(values) %#ok<DEFNU>
% Unit test for dataTags mergedataTags method
fprintf('\nUnit tests for getText method of dataTags\n');
fprintf('The text from an object created in text is valid\n');
[f1, h1, e1] = dataTags.split([';;' values.eventList1], false);
assertTrue(isempty(f1));
eT1 = dataTags(h1, e1);
theText = eT1.getText();
[f1, h2, e2] = dataTags.split(theText, false);
assertTrue(strcmpi(f1, 'type'));
eT2 = dataTags(h2, e2);
assert(isvalid(eT2));
theJson = eT1.getJson();
x1 = dataTags.json2Mat(theJson);
fprintf('The text from an object created from text is valid\n');
assertTrue(isstruct(x1));
events = x1.events;
assertEqual(length(events), 2);
assertEqual(length(events(1).tags) + length(events(2).tags), 2);




% values.eventList1 = '1,Trigger,code 1,/my/tag1, /my/tag2; 2,Trigger2,t2,';
% values.baseList1 = '1,Button Press,code 1,/my/tag1, /my/tag3';
% values.eventList2 = '2,Trigger,code 2,/my/tag1, /my/tag2';
% values.baseList2 = '3,Trigger,code 3,/my/tag3, /my/tag4';
% values.eventList3 = '4,RT,code 4,/my/tag1, /my/tag2';
% values.baseList3 = '4,RT,code 4,/my/tag1, /my/tag2';
% tagList1 = mergeTags(values.eventList1, values.baseList1, 'code');
% [~, ~, ~, tags] = parseEvent(tagList1);
% assertTrue(isequal(length(tags), 3));
% fprintf('It should merge correctly when name match is specified with matches found\n');
% tagList2 = mergeTags(values.eventList2, values.baseList2, 'name');
% [~, ~, ~, tags] = parseEvent(tagList2);
% assertTrue(isequal(length(tags), 4));
% fprintf('It should merge correctly when both match is specified with matches found\n');
% tagList3 = mergeTags(values.eventList3, values.baseList3, 'both');
% [~, ~, ~, tags] = parseEvent(tagList3);
% assertTrue(isequal(length(tags), 2));
% fprintf('It should merge correctly when code match is specified with matches not found\n');
% tagList4 = mergeTags(values.eventList1, values.baseList2, 'code');
% [~, ~, ~, tags] = parseEvent(tagList4);
% assertTrue(isequal(length(tags), 2));
% fprintf('It should merge correctly when name match is specified with matches not found\n');
% tagList5 = mergeTags(values.eventList1, values.baseList1, 'name');
% [~, ~, ~, tags] = parseEvent(tagList5);
% assertTrue(isequal(length(tags), 2));
% fprintf('It should merge correctly when both match is specified with matches not found\n');
% tagList6 = mergeTags(values.eventList1, values.baseList1, 'both');
% [~, ~, ~, tags] = parseEvent(tagList6);
% assertTrue(isequal(length(tags), 2));
% fprintf('It should merge correctly when no match (default code) is specified with matches found\n');
% tagList7 = mergeTags(values.eventList1, values.baseList1);
% [~, ~, ~, tags] = parseEvent(tagList7);
% assertTrue(isequal(length(tags), 3));
% fprintf('It should merge correctly when no match (default code) is specified with matches not found\n');
% tagList8 = mergeTags(values.eventList1, values.baseList2);
% [~, ~, ~, tags] = parseEvent(tagList8);
% assertTrue(isequal(length(tags), 2));

function testCreateEvent(values) %#ok<INUSD,DEFNU>
% Unit test for dataTags createEvent static method
fprintf('\nUnit tests for createEvent static method of dataTags\n');

fprintf('It should throw an exception for no arguments\n');
f = @() dataTags.createEvent();
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should create a valid structure when one argument invalid\n');
event = dataTags.createEvent('3', 'event 3', {'a', 'b', 'c'});
assertTrue(isstruct(event));
assertTrue(dataTags.validateEvent(event));

function testText2Event(values) %#ok<INUSD,DEFNU>
% Unit test for dataTags .parseCommaEvent static method
fprintf('\nUnit tests for parseCommaEvent static method of dataTags\n');

fprintf('It should return empty values when input is empty\n');
theStruct = dataTags.text2Event('');

assertTrue(isempty(theStruct.label));
assertTrue(isempty(theStruct.description));
assertTrue(isempty(theStruct.tags));
fprintf('It should return filled values when there is a valid event string\n');
theStruct1 = dataTags.text2Event('Trigger,code 2,/my/tag1, /my/tag2');
assertTrue(strcmpi(theStruct1.label, 'Trigger'));
assertTrue(strcmpi(theStruct1.description, 'code 2'));
assertEqual(length(theStruct1.tags), 2);
fprintf('It should return filled values when there are no tags\n');
theStruct2 = dataTags.text2Event('Trigger,code 1,');
assertEqual(length(theStruct2), 1);
fprintf('The tags should be empty after reformatting\n');
[rEvent2, valid2] = dataTags.reformatEvent(theStruct2);
assertTrue(valid2);
assertTrue(isempty(rEvent2.tags));
fprintf('It should return filled values when there is 1 tag\n');
theStruct3 = dataTags.text2Event('Trigger,code 1,/my/tag1,');
assertEqual(length(theStruct3), 1);
[rEvent3, valid3] = dataTags.reformatEvent(theStruct3);
assertTrue(valid3);
assertTrue(ischar(rEvent3.tags));

function testReformatEvent(values) %#ok<INUSD,DEFNU>
% Unit test for dataTags reformatEvent static method
fprintf('\nUnit tests for reformatEvent static method of dataTags\n');

fprintf('It should be not be valid for empty events\n');
[event, valid] = dataTags.reformatEvent(''); %#ok<ASGLU>
assertTrue(~valid);
fprintf('It should be not be valid for blank label\n');
event2 = struct('label', '  ', 'description', '', 'Tags', '');
[events2a, valid2] = dataTags.reformatEvent(event2); %#ok<ASGLU>
assertTrue(~valid2);

% function testGetTextEvents(values) %#ok<DEFNU>
% % Unit test for dataTags getTextEvents method
% fprintf('\nUnit tests for getTextEventsc method of dataTags\n');
% fprintf('It should work for previously tagged EEG\n');
% load('EEGTagged.mat');
% jString = EEG.etc.eventHedTags;
% eTags = dataTags(jString);
% events = eTags.getEvents();
% assertEqual(length(events), 2);
% eString = eTags.getTextEvents();
% assertTrue(~isempty(eString));

function testEvent2Json(values) %#ok<DEFNU>
% Unit test for dataTags static getJsonEvent method
fprintf('\nUnit tests for getJsonEvent static method of dataTags\n');
fprintf('It should throw an exception if the event is empty\n');
f = @() dataTags.event2Json(values.emptyEvent);
assertAltExceptionThrown(f, {'MATLAB:nonStrucReference'});
fprintf('It should throw an exception if some fields are missing\n');
f = @() dataTags.event2Json(values.eventMissingFields);
assertAltExceptionThrown(f, {'MATLAB:nonExistentField'});
fprintf('It should work if the tags field is empty\n');
tagsEmpty = dataTags.event2Json(values.eventEmptyTags);
theStruct = loadjson(tagsEmpty);
savejson('', theStruct);
fprintf('It should work for one event\n');
oneEvent = dataTags.event2Json(values.oneEvent);
theStruct = loadjson(oneEvent);
savejson('', theStruct);

function testEvent2Text(values) %#ok<DEFNU>
fprintf('\nUnit tests for gettextEvent static method of dataTags\n');
fprintf('It should throw an exception if the event is empty\n');
f = @() dataTags.event2Text(values.emptyEvent);
assertAltExceptionThrown(f, {'MATLAB:nonStrucReference'});
fprintf('It should throw an exception if some fields are missing\n');
f = @() dataTags.event2Text(values.eventMissingFields);
assertAltExceptionThrown(f, {'MATLAB:nonExistentField'});
fprintf('It should work if the tags field is empty\n');
tagsEmpty = dataTags.event2Text(values.eventEmptyTags);
theStruct = dataTags.text2Event(tagsEmpty);
savejson('', theStruct);
fprintf('It should work for one event\n');
oneEvent = dataTags.event2Text(values.oneEvent);
theStruct = dataTags.text2Event(oneEvent);
savejson('', theStruct);

function testEvents2Json(values) %#ok<INUSD,DEFNU>
fprintf('\nUnit tests for events2Json static method of dataTags\n');
fprintf('It should work if the events cell array is empty\n');
eText = dataTags.events2Json('');
theStruct = dataTags.json2Events(eText);
assertTrue(isempty(theStruct));

function testLoadTagsFile(values) %#ok<DEFNU>
fprintf('\nUnit tests for loadTagsFile static method of dataTags\n');
fprintf('It should return an empty value when file contains no dataTags\n');
bT1 = dataTags.loadTagFile(values.noTagsFile);
assertTrue(isempty(bT1));
fprintf('It should return an dataTags object when only one variable in file\n');
bT2 = dataTags.loadTagFile(values.oneTagsFile);
assertTrue(isa(bT2, 'dataTags'));
fprintf('It should return an dataTags object when it is not first variable in file\n');
bT3 = dataTags.loadTagFile(values.otherTagsFile);
assertTrue(isa(bT3, 'dataTags'));

