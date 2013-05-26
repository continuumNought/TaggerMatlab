function test_suite = test_fieldMap %#ok<STOUT>
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
values.noTagsFile = 'EEGEpoch.mat';
values.oneTagsFile = 'dTags.mat';
values.otherTagsFile = 'dTagsOther.mat';


function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test



function testValid(values) %#ok<DEFNU>
% Unit test for fieldMap constructor valid JSON
fprintf('\nUnit tests for fieldMap valid JSON constructor\n');

fprintf('It should create a valid fieldMap object for a valid JSON events string\n');
[xml1, field1,  events1] = tagMap.split(values.eJSON1, true);
assertTrue(strcmpi(field1, 'type'));
obj1 = fieldMap(xml1);
assertTrue(isvalid(obj1));
fprintf('It should have the right number of events\n');
obj1.addEvents(field1, events1, 'Merge');
events = obj1.getMaps();
assertEqual(length(events), 1);
fprintf('It should create a valid object for a valid text string\n');
testString = [values.eStruct1.xml ';type;'  values.eventList1];
[xml2, field2, events2] = tagMap.split(testString, false);
assertTrue(strcmpi(field2, 'type'));
obj2 = fieldMap(xml2);
assertTrue(isvalid(obj2));
fprintf('It should have the right number of events when there is one field\n');
for k = 1:length(events2)
    obj2.addEvent(field2, events2(k), 'Merge');
end
events = obj2.getMaps();
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
events = obj2.getMaps();
assertEqual(length(events), 2);
for k = 1:length(events2)
    obj2.addEvent('grapes', events2(k), 'Merge');
end
events = obj2.getMaps();
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
% Unit test for fieldMap constructor empty or invalid
fprintf('\nUnit tests for fieldMap empty\n');

fprintf('It should throw  are no arguments\n');
f = @() fieldMap();
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should output a warning if an empty string is used ---WARNING\n');
obj1 = fieldMap('');
assertTrue(isvalid(obj1));
fprintf('---the resulting structure should have the right fields\n');
dStruct1 = obj1.getStruct();
assertTrue(isstruct(dStruct1));
assertEqual(length(fieldnames(dStruct1)), 2);
assertElementsAlmostEqual(sum(isfield(dStruct1, {'xml', 'map'})), 2);
assertTrue(~isempty(dStruct1.xml));
assertTrue(isempty(dStruct1.map));


function testMerge(values) %#ok<DEFNU>
% Unit test for fieldMap merge method
fprintf('\nUnit tests for fieldMap merge\n');
fprintf('It merge a valid fieldMap object\n');
dTags = fieldMap('');

dTags1 = findtags(values.EEGEpoch);
assertEqual(length(dTags1.getMaps()), 2);
assertEqual(length(dTags.getMaps()), 0);
dTags.merge(dTags1, 'Merge');
assertEqual(length(dTags.getMaps()), 2);

function testLoadTagsFile(values) %#ok<DEFNU>
fprintf('\nUnit tests for loadTagsFile static method of fieldMap\n');
fprintf('It should return an empty value when file contains no fieldMap\n');
bT1 = fieldMap.loadFieldMap(values.noTagsFile);
assertTrue(isempty(bT1));
fprintf('It should return an fieldMap object when only one variable in file\n');
bT2 = fieldMap.loadFieldMap(values.oneTagsFile);
assertTrue(isa(bT2, 'fieldMap'));
fprintf('It should return an fieldMap object when it is not first variable in file\n');
bT3 = fieldMap.loadFieldMap(values.otherTagsFile);
assertTrue(isa(bT3, 'fieldMap'));

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
