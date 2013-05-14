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
types = {'RT', 'Trigger', 'Missed'};
eStruct = struct('field', 'type', 'xml', '', 'events', 'def');
tags = {'/Time-Locked Event/Stimulus/Visual/Shape/Ellipse/Circle', ...
        '/Time-Locked Event/Stimulus/Visual/Fixation Point', ...
        '/Time-Locked Event/Stimulus/Visual/Uniform Color/Black'};
sE = struct('label', types, 'description', types, 'tags', '');
sE(1).tags = tags;
eStruct.events = sE;
eJSON1 = savejson('', eStruct);
values.eStruct1 = eStruct;
values.eJSON1 = eJSON1;
load EEGEpoch.mat;
values.EEGEpoch = EEGEpoch;
load EEGShoot.mat;
values.EEGShoot = EEGShoot;


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
    obj1.addEvent(field1, events1(k), 'Merge');
end
events = obj1.getEventTags();
assertEqual(length(events), 1);
fprintf('It should create a valid object for a valid text string\n');
testString = ['type;' values.eStruct1.xml ';' values.eventList1];
[field2, xml2, events2] = eventTags.split(testString, false);
assertTrue(strcmpi(field2, 'type'));
obj2 = dataTags(xml2);
assertTrue(isvalid(obj2));
fprintf('It should have the right number of events when there is one field\n');
for k = 1:length(events2)
    obj2.addEvent(field2, events2(k), 'Merge');
end
events = obj2.getEventTags();
assertEqual(length(events), 1);
fprintf('It should produce right structure when one field\n');
dStruct = obj2.getStruct();
assertTrue(isfield(dStruct, 'xml'));
assertTrue(isfield(dStruct, 'map'));
p = dStruct.map;
assertTrue(isfield(p, 'field'));
assertTrue(isfield(p, 'events'));
assertEqual(length(p.events), 2);
fprintf('It should have the right number of events with multiple fields\n');
for k = 1:length(events2)
    obj2.addEvent('banana', events2(k), 'Merge');
end
events = obj2.getEventTags();
assertEqual(length(events), 2);
for k = 1:length(events2)
    obj2.addEvent('grapes', events2(k), 'Merge');
end
events = obj2.getEventTags();
assertEqual(length(events), 3);
dStruct = obj2.getStruct();
assertTrue(isfield(dStruct, 'xml'));
assertTrue(isfield(dStruct, 'map'));
p = dStruct.map;
assertEqual(length(p), 3);
assertTrue(isfield(p(1), 'field'));
assertTrue(isfield(p(1), 'events'));
assertEqual(length(p(1).events), 2);

function testEmptyOrInvalid(values) %#ok<INUSD,DEFNU>
% Unit test for dataTags constructor empty or invalid
fprintf('\nUnit tests for dataTags empty\n');

fprintf('It should throw  are no arguments\n');
f = @() dataTags();
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should output a warning if an empty string is used ---WARNING\n');
obj1 = dataTags('');
assertTrue(isvalid(obj1));
fprintf('---the resulting structure should have the right fields\n');
dStruct1 = obj1.getStruct();
assertTrue(isstruct(dStruct1));
assertEqual(length(fieldnames(dStruct1)), 2);
assertElementsAlmostEqual(sum(isfield(dStruct1, {'xml', 'map'})), 2);
assertTrue(~isempty(dStruct1.xml));
assertTrue(isempty(dStruct1.map));



