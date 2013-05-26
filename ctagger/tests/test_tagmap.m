function test_suite = test_tagMap %#ok<STOUT>
initTestSuite;

function values = setup %#ok<DEFNU>
types = {'RT', 'Trigger', 'Missed'};
eStruct = struct('xml', 'abc', 'field', 'type',  'events', 'def');
tags = {'/Time-Locked Event/Stimulus/Visual/Shape/Ellipse/Circle', ...
        '/Time-Locked Event/Stimulus/Visual/Fixation Point', ...
        '/Time-Locked Event/Stimulus/Visual/Uniform Color/Black'};
sE = struct('label', types, 'description', types, 'tags', '');
sE(1).tags = tags;
eStruct.field = 'type';
eStruct.events = sE;
eStruct.xml = fileread('HEDSpecification1.3.xml');
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

values.oneType = ['RT,User response,' ...
        '/Time-Locked Event/Stimulus/Visual/Shape/Ellipse/Circle,' ...
        '/Time-Locked Event/Stimulus/Visual/Uniform Color/Black'];
values.typeValues = ['RT,User response,' ...
        '/Time-Locked Event/Stimulus/Visual/Shape/Ellipse/Circle,' ...
        '/Time-Locked Event/Stimulus/Visual/Uniform Color/Black;' ...
        'Trigger,User stimulus,,;Missed,User failed to respond,'];


function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test


function testSplit(values) %#ok<DEFNU>
% Unit test for tagMap constructor valid JSON
fprintf('\nUnit tests for tagMap split static method \n');

fprintf('It should split a valid JSON string\n');
[xml1, field1, events1] = tagMap.split(values.eJSON1, true);
fprintf('It should have the right field\n');
assertTrue(strcmpi(field1, 'type'));
fprintf('It should have the right number of events\n');
assertEqual(length(events1), 3);
fprintf('It should return the events in a structure\n');
assertTrue(isstruct(events1));
fprintf('It should have the right XML string\n');
assertTrue(strcmpi(xml1, values.eStruct1.xml));
fprintf('It should split a valid text string \n');
testString = [values.eStruct1.xml ';type;' values.eventList1];
[xml2, field2, events2] = tagMap.split(testString, false);
fprintf('It should have the right field\n');
assertTrue(strcmpi(field2, 'type'));
fprintf('It should have the right XML string\n');
assertTrue(strcmpi(strtrim(xml2), strtrim(values.eStruct1.xml)));
fprintf('It should have the right number of events\n');
assertEqual(length(events2), 2);
fprintf('It should return events in a structure when multiple events\n');
assertTrue(isstruct(events2));

function testValid(values) %#ok<DEFNU>
% Unit test for tagMap constructor valid JSON
fprintf('\nUnit tests for tagMap valid JSON constructor\n');

fprintf('It should create a valid object for a valid JSON events string\n');
[xml1, field1, events1] = tagMap.split(values.eJSON1, true);
assertTrue(strcmpi(field1, 'type'));
obj1 = tagMap(xml1, events1);
assertTrue(isvalid(obj1));
fprintf('It should have the right number of events\n');
events = obj1.getEvents();
assertEqual(length(events), 3);
fprintf('It should create a valid object for a valid text string\n');
testString = [ values.eStruct1.xml ';type;' values.eventList1];
[xml2, field2, events2] = tagMap.split(testString, false);
assertTrue(strcmpi(field2, 'type'));
obj2 = tagMap(xml2,events2);
assertTrue(isvalid(obj2));
fprintf('It should have the right number of events\n');
events = obj2.getEvents();
assertEqual(length(events), 2);

function testEmptyOrInvalid(values) %#ok<INUSD,DEFNU>
% Unit test for tagMap constructor empty or invalid
fprintf('\nUnit tests for tagMap empty or invalid JSON\n');

fprintf('It should throw  are no arguments\n');
f = @() tagMap();
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should output a warning if an empty string is used ---WARNING\n');
obj1 = tagMap('', '');
assertTrue(isvalid(obj1));
fprintf('---the resulting structure should have the right fields\n');
eStruct1 = obj1.getStruct();
assertTrue(isstruct(eStruct1));
assertEqual(length(fieldnames(eStruct1)), 3);
assertElementsAlmostEqual(sum(isfield(eStruct1, {'xml', 'field', 'events'})), 3);
assertTrue(~isempty(eStruct1.xml));
assertTrue(isempty(eStruct1.events));


function testMergeXml(values) %#ok<INUSD,DEFNU>
% Unit test for tagMap mergeXml static method
fprintf('\nUnit tests for mergeXml static method of tagMap\n');

fprintf('It should merge XML when both tag sets are empty\n');
obj1 = tagMap('', '');
obj1.mergeXml('');
xml1 = obj1.getXml;
assertTrue(~isempty(xml1));
obj1.mergeXml(xml1);
%assertTrue(strcmpi(strtrim(obj1.getXml()), strtrim(xml1)));

function testMerge(values) %#ok<DEFNU>
% Unit test for tagMap merge method
fprintf('\nUnit tests for merge method of tagMap\n');

fprintf('It should merge correctly when code match is specified with matches found\n');
[h1, f1, e1] = tagMap.split([';;' values.eventList1], false);
[h1a, f1a, b1] = tagMap.split([';;' values.baseList1], false);
assertTrue(isempty(f1));
assertTrue(isempty(f1a));
e1 = tagMap(h1, e1);
b1 = tagMap(h1a, b1);
e1.merge(b1, 'OnlyTags');
eEvents = e1.getEvents();
assertEqual(length(eEvents), 2);
event1 = e1.getEvent('Trigger');
assertTrue(~isempty(event1));
fprintf('It should correctly merge tags when event codes match\n');
assertEqual(length(event1.tags), 3);
fprintf('It should have not merge events when argument is empty\n');
e1.merge('', 'OnlyTags');
eEvents = e1.getEvents();
assertEqual(length(eEvents), 2);
e1.merge('', 'Merge');
eEvents = e1.getEvents();
assertEqual(length(eEvents), 2);
fprintf('It should not include extra events if OnlyTags is true\n');
[h3, f3, b3] = tagMap.split([';;' values.baseList3], false);
assertTrue(isempty(f3));
b3 = tagMap(h3, b3);
e1.merge(b3, 'OnlyTags');
eEvents = e1.getEvents();
assertEqual(length(eEvents), 2);
fprintf('It should include extra events if OnlyTags is false\n');
e1.merge(b3, 'Merge');
eEvents = e1.getEvents();
assertEqual(length(eEvents), 3);

fprintf('It should work when PreservePrefix is true\n');
[h2, f2, e2] = tagMap.split([';;' values.eventList1], false);
assertTrue(isempty(f2));
eT2 = tagMap(h2, e2, 'PreservePrefix', true);
eT2.merge(b1, 'OnlyTags');
eEvents = eT2.getEvents();
assertEqual(length(eEvents), 2);
event2 = eT2.getEvent('Trigger');
assertTrue(~isempty(event2));
fprintf('It should correctly merge tags when event codes match\n');
assertEqual(length(event2.tags), 4);

fprintf('It should not merge the events when fields don''t match\n');
[ h3, f3, e3] = tagMap.split([';;' values.eventList1], false);
assertTrue(isempty(f3));
eT3 = tagMap(h3, e3);
assertEqual(length(eT3.getEvents()), 2);
assertTrue(strcmpi(eT3.getField(), 'type'));
[h4, f4, e4] = tagMap.split([';;' values.baseList3], false);
assertTrue(isempty(f4));
eT4 = tagMap(h4, e4);
assertEqual(length(eT4.getEvents()), 2);
assertTrue(strcmpi(eT4.getField(), 'type'));
eT3.merge(eT4, 'Merge');
assertEqual(length(eT3.getEvents()), 3);
eT3a = tagMap(h3, e3);
eT4a = tagMap(h4, e4, 'Field', 'balony');
eT3a.merge(eT4a, 'Merge');
assertEqual(length(eT3a.getEvents()), 2);

function testGetText(values) %#ok<DEFNU>
% Unit test for tagMap mergeTagMap method
fprintf('\nUnit tests for getText method of tagMap\n');
fprintf('The text from an object created in text is valid\n');
[h1, f1, e1] = tagMap.split([';;' values.eventList1], false);
assertTrue(isempty(f1));
eT1 = tagMap(h1, e1);
theText = eT1.getText();
[h2, f2, e2] = tagMap.split(theText, false);
assertTrue(strcmpi(f2, 'type'));
eT2 = tagMap(h2, e2);
assert(isvalid(eT2));
theJson = eT1.getJson();
x1 = tagMap.json2Mat(theJson);
fprintf('The text from an object created from text is valid\n');
assertTrue(isstruct(x1));
events = x1.events;
assertEqual(length(events), 2);
assertEqual(length(events(1).tags) + length(events(2).tags), 2);

function testCreateEvent(values) %#ok<INUSD,DEFNU>
% Unit test for tagMap createEvent static method
fprintf('\nUnit tests for createEvent static method of tagMap\n');

fprintf('It should throw an exception for no arguments\n');
f = @() tagMap.createEvent();
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should create a valid structure when one argument invalid\n');
event = tagMap.createEvent('3', 'event 3', {'a', 'b', 'c'});
assertTrue(isstruct(event));
assertTrue(tagMap.validateEvent(event));

function testText2Event(values) %#ok<INUSD,DEFNU>
% Unit test for tagMap .parseCommaEvent static method
fprintf('\nUnit tests for parseCommaEvent static method of tagMap\n');

fprintf('It should return empty values when input is empty\n');
theStruct = tagMap.text2Event('');

assertTrue(isempty(theStruct.label));
assertTrue(isempty(theStruct.description));
assertTrue(isempty(theStruct.tags));
fprintf('It should return filled values when there is a valid event string\n');
theStruct1 = tagMap.text2Event('Trigger,code 2,/my/tag1, /my/tag2');
assertTrue(strcmpi(theStruct1.label, 'Trigger'));
assertTrue(strcmpi(theStruct1.description, 'code 2'));
assertEqual(length(theStruct1.tags), 2);
fprintf('It should return filled values when there are no tags\n');
theStruct2 = tagMap.text2Event('Trigger,code 1,');
assertEqual(length(theStruct2), 1);
fprintf('The tags should be empty after reformatting\n');
[rEvent2, valid2] = tagMap.reformatEvent(theStruct2);
assertTrue(valid2);
assertTrue(isempty(rEvent2.tags));
fprintf('It should return filled values when there is 1 tag\n');
theStruct3 = tagMap.text2Event('Trigger,code 1,/my/tag1,');
assertEqual(length(theStruct3), 1);
[rEvent3, valid3] = tagMap.reformatEvent(theStruct3);
assertTrue(valid3);
assertTrue(ischar(rEvent3.tags));
fprintf('It should return the correct number of tags when there are blank tags\n');
theStruct4 = tagMap.text2Event('Trigger,code 2,  , /my/tag2');
assertTrue(strcmpi(theStruct4.label, 'trigger'));
assertEqual(length(theStruct4.tags), 1);
theStruct5 = tagMap.text2Event('Trigger,code 2,  , ');
assertTrue(strcmpi(theStruct5.label, 'trigger'));
assertTrue(isempty(theStruct5.tags));

function testReformatEvent(values) %#ok<INUSD,DEFNU>
% Unit test for tagMap reformatEvent static method
fprintf('\nUnit tests for reformatEvent static method of tagMap\n');

fprintf('It should be not be valid for empty events\n');
[event, valid] = tagMap.reformatEvent(''); %#ok<ASGLU>
assertTrue(~valid);
fprintf('It should be not be valid for blank label\n');
event2 = struct('label', '  ', 'description', '', 'Tags', '');
[events2a, valid2] = tagMap.reformatEvent(event2); %#ok<ASGLU>
assertTrue(~valid2);

function testEvent2Json(values) %#ok<DEFNU>
% Unit test for tagMap static getJsonEvent method
fprintf('\nUnit tests for getJsonEvent static method of tagMap\n');
fprintf('It should throw an exception if the event is empty\n');
f = @() tagMap.event2Json(values.emptyEvent);
assertAltExceptionThrown(f, {'MATLAB:nonStrucReference'});
fprintf('It should throw an exception if some fields are missing\n');
f = @() tagMap.event2Json(values.eventMissingFields);
assertAltExceptionThrown(f, {'MATLAB:nonExistentField'});
fprintf('It should work if the tags field is empty\n');
tagsEmpty = tagMap.event2Json(values.eventEmptyTags);
theStruct = loadjson(tagsEmpty);
savejson('', theStruct);
fprintf('It should work for one event\n');
oneEvent = tagMap.event2Json(values.oneEvent);
theStruct = loadjson(oneEvent);
savejson('', theStruct);

function testEvent2Text(values) %#ok<DEFNU>
fprintf('\nUnit tests for event2Text static method of tagMap\n');
fprintf('It should throw an exception if the event is empty\n');
f = @() tagMap.event2Text(values.emptyEvent);
assertAltExceptionThrown(f, {'MATLAB:nonStrucReference'});
fprintf('It should throw an exception if some fields are missing\n');
f = @() tagMap.event2Text(values.eventMissingFields);
assertAltExceptionThrown(f, {'MATLAB:nonExistentField'});
fprintf('It should work if the tags field is empty\n');
tagsEmpty = tagMap.event2Text(values.eventEmptyTags);
theStruct = tagMap.text2Event(tagsEmpty);
savejson('', theStruct);
fprintf('It should work for one event\n');
oneEvent = tagMap.event2Text(values.oneEvent);
theStruct = tagMap.text2Event(oneEvent);
savejson('', theStruct);

function testEvents2Json(values) %#ok<INUSD,DEFNU>
fprintf('\nUnit tests for events2Json static method of tagMap\n');
fprintf('It should work if the events cell array is empty\n');
eText = tagMap.events2Json('');
theStruct = tagMap.json2Events(eText);
assertTrue(isempty(theStruct));


function testText2Events(values) %#ok<DEFNU>
fprintf('\nUnit tests for text2Events static method of tagMap\n');
fprintf('It should work if the string is empty\n');
eStruct1 = tagMap.text2Event(values.oneType);
assertTrue(isstruct(eStruct1));
eStruct2 = tagMap.text2Events(values.oneType);
assertTrue(isstruct(eStruct2));
assertEqual(length(eStruct2), 1);
eStruct3 = tagMap.text2Events(values.typeValues);
assertTrue(isstruct(eStruct3));
assertEqual(length(eStruct3), 3);
assertEqual(length(eStruct3(1).tags), 2);
assertEqual(length(eStruct3(2).tags), 0);
assertEqual(length(eStruct3(3).tags), 0);

function testText2Mat(values) %#ok<INUSD,DEFNU>
fprintf('\nUnit tests for text2Events static method of tagMap\n');
fprintf('It should work if the string is empty\n');

function testClone(values) %#ok<DEFNU>
fprintf('\nUnit tests for clone method of tagMap\n');
fprintf('It should correctly clone a tagMap object\n');
[xml1, field1, events1] = tagMap.split(values.eJSON1, true);
obj1 = tagMap(xml1, events1);
assertTrue(strcmpi (field1, obj1.getField()));
obj2 = obj1.clone();
assertTrue(isa(obj2, 'tagMap'));
fprintf('The fields of the two objects should agree\n');
assertTrue(strcmpi(obj1.getField(), obj2.getField()));
keys1 = obj1.getLabels();
keys2 = obj2.getLabels();
fprintf('The two objects should have the same number of labels\n');
assertEqual(length(keys1), length(keys2));
