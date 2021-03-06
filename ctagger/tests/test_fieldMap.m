function test_suite = test_fieldMap %#ok<STOUT>
initTestSuite;

function values = setup %#ok<DEFNU>
types = {'RT', 'Trigger', 'Missed'};
eStruct = struct('field', 'type', 'values', 'def');
tags = {'/Time-Locked Event/Stimulus/Visual/Shape/Ellipse/Circle', ...
    '/Time-Locked Event/Stimulus/Visual/Fixation Point', ...
    '/Time-Locked Event/Stimulus/Visual/Uniform Color/Black'};
sE = struct('label', types, 'description', types, 'tags', '');
sE(1).tags = tags;
eStruct.field = 'type';
values.xml = fileread('HEDSpecification1.3.xml');
values.xmlSchema = fileread('HEDSchema.xsd');
eStruct.values = sE;
values.eJSON1 = savejson('', eStruct);
values.eStruct1 = eStruct;
values.eventList1 = 'Trigger,code 1,/my/tag1, /my/tag2;Trigger2,t2,';
values.baseList1 = 'Trigger,code 1,/my/tag1/a, /my/tag3';
values.eventList2 = 'Trigger,code 2,/my/tag1, /my/tag2';
values.baseList2 = 'Trigger,code 3,/my/tag3, /my/tag4';
values.eventList3 = 'RT,code 4,/my/tag1, /my/tag2';
values.baseList3 = 'Trigger,code 1,/my/tag4, /my/tag2; RT,code 4,/my/tag1, /my/tag2';

values.emptyValue = '';
values.valueMissingFields = struct('label', types);
values.valueEmptyTags = struct('label', types, 'description', types, 'tags', '');
values.oneValue = struct('label', 'abc type', 'description', '', 'tags', '/a/b');
types = {'RT', 'Trigger', 'Missed'};
eStruct = struct('field', 'type', 'values', 'def');
tags = {'/Time-Locked Event/Stimulus/Visual/Shape/Ellipse/Circle', ...
    '/Time-Locked Event/Stimulus/Visual/Fixation Point', ...
    '/Time-Locked Event/Stimulus/Visual/Uniform Color/Black'};
sE = struct('label', types, 'description', types, 'tags', '');
sE(1).tags = tags;
eStruct.values = sE;
eJSON1 = savejson('', eStruct);
values.eStruct1 = eStruct;
values.eJSON1 = eJSON1;
load EEGEpoch.mat;
values.EEGEpoch = EEGEpoch;
values.noTagsFile = 'EEGEpoch.mat';
values.oneTagsFile = 'fMapOne.mat';
values.otherTagsFile = 'fMapTwo.mat';
typeValues = tagMap.text2Values(['RT,User response,' ...
    '/Time-Locked Event/Stimulus/Visual/Shape/Ellipse/Circle,' ...
    '/Time-Locked Event/Stimulus/Visual/Uniform Color/Black;' ...
    'Trigger,User stimulus,,;Missed,User failed to respond,']);
codeValues = tagMap.text2Values(['1,User response,' ...
    '/Time-Locked Event/Stimulus/Visual/Shape/Ellipse/Square,' ...
    '/Time-Locked Event/Stimulus/Visual/Uniform Color/Blue;' ...
    '2,User stimulus,,;3,User failed to respond,']);
% Read in the HED schema
latestHed = 'HEDSpecification1.3.xml';
values.data.etc.tags.xml = fileread(latestHed);
map(3) = struct('field', '', 'values', '');
map(1).field = 'type';
map(1).values = typeValues;
map(2).field = 'code';
map(2).values = codeValues;
map(3).field = 'group';
map(3).values = codeValues;
values.data.etc.tags.map = map;
values.data.event = struct('type', {'RT', 'Trigger'}, 'code', {'1', '2'});


function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test

function testAddValue(values) %#ok<DEFNU>
% Unit test for fieldMap adding structure events
fprintf('\nUnit tests for fieldMap adding structure events\n');
fprintf('It should allow adding of a single type\n');
obj1 = fieldMap();
assertTrue(isvalid(obj1));
obj1.addValues('type', values.eStruct1.values);
tags1 = obj1.getTags('type', 'RT');
assertEqual(length(tags1), 3);

function test_json(values) %#ok<DEFNU>
% Unit test for fieldMap constructor valid JSON
fprintf('\nUnit tests for fieldMap valid json values\n');

fprintf('It should create a valid fieldMap object for a valid JSON string\n');
[field1,  values1] = tagMap.split(values.eJSON1, true);
assertTrue(strcmpi(field1, 'type'));
obj1 = fieldMap();
assertTrue(isvalid(obj1));
fprintf('It should have the right number of values\n');
obj1.addValues(field1, values1);
values2 = obj1.getMaps();
assertEqual(length(values2), 1);
assertTrue(isa(values2{1}, 'tagMap'));

function test_text(values) %#ok<DEFNU>
% Unit test for fieldMap constructor valid text values
fprintf('\nUnit tests for fieldMap valid text values\n');
fprintf('It should create a valid object for a valid text string\n');
testString = ['type;'  values.eventList1];
[field2, values2s] = tagMap.split(testString, false);
assertTrue(strcmpi(field2, 'type'));
obj2 = fieldMap();
assertTrue(isvalid(obj2));
fprintf('It should have the right number of values when there is one field\n');
obj2.addValues(field2, values2s);
values2 = obj2.getMaps();
assertEqual(length(values2), 1);
assertTrue(isa(values2{1}, 'tagMap'));

fprintf('It should produce right structure when one field\n');
dStruct = obj2.getStruct();
assertTrue(isfield(dStruct, 'xml'));
assertTrue(isfield(dStruct, 'map'));
p = dStruct.map;
assertTrue(isfield(p, 'field'));
assertTrue(isfield(p, 'values'));
assertEqual(length(p.values), 2);

fprintf('It should have the right number of values with multiple fields\n');
obj2.addValues('banana', values2s);
values3 = obj2.getMaps();
assertEqual(length(values3), 2);
obj2.addValues('grapes', values2s);
values4 = obj2.getMaps();
assertEqual(length(values4), 3);
dStruct = obj2.getStruct();
assertTrue(isfield(dStruct, 'xml'));
assertTrue(isfield(dStruct, 'map'));
p = dStruct.map;
assertEqual(length(p), 3);
assertTrue(isfield(p(1), 'field'));
assertTrue(isfield(p(1), 'values'));
assertEqual(length(p(1).values), 2);

function testEmptyOrInvalid(values) %#ok<INUSD,DEFNU>
% Unit test for fieldMap constructor empty or invalid
% fprintf('\nUnit tests for fieldMap empty\n');
%
% fprintf('It should throw  are no arguments\n');
% f = @() fieldMap();
% assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});
%
% fprintf('It should output a warning if an empty string is used ---WARNING\n');
% obj1 = fieldMap('');
% assertTrue(isvalid(obj1));
% fprintf('---the resulting structure should have the right fields\n');
% dStruct1 = obj1.getStruct();
% assertTrue(isstruct(dStruct1));
% assertEqual(length(fieldnames(dStruct1)), 2);
% assertElementsAlmostEqual(sum(isfield(dStruct1, {'xml', 'map'})), 2);
% assertTrue(~isempty(dStruct1.xml));
% assertTrue(isempty(dStruct1.map));


function testMerge(values) %#ok<DEFNU>
% Unit test for fieldMap merge method
fprintf('\nUnit tests for fieldMap merge\n');
fprintf('It merge a valid fieldMap object\n');
dTags = fieldMap();
dTags1 = findtags(values.EEGEpoch);
assertEqual(length(dTags1.getMaps()), 2);
assertEqual(length(dTags.getMaps()), 0);
dTags.merge(dTags1, 'Merge', {}, {});
assertEqual(length(dTags.getMaps()), 2);
fprintf('It should exclude the appropriate fields\n');
dTags2 = fieldMap();
dTags2.merge(dTags1, 'Merge', {'position'}, {});
assertEqual(length(dTags2.getMaps()), 1);

function testLoadFieldMap(values) %#ok<DEFNU>
fprintf('\nUnit tests for loadFieldMap static method of fieldMap\n');
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
%____________TODO
fprintf('\nUnit tests for clone method of fieldMap\n');
fprintf('It should correctly clone a fieldMap object\n');
[field1, events1] = tagMap.split(values.eJSON1, true);
obj1 = tagMap();
for k = 1:length(events1)
    obj1.addValue(events1(k));
end
assertTrue(strcmpi (field1, obj1.getField()));

obj2 = obj1.clone();
assertTrue(isa(obj2, 'tagMap'));
fprintf('The fields of the two objects should agree\n');
assertTrue(strcmpi(obj1.getField(), obj2.getField()));
keys1 = obj1.getLabels();
keys2 = obj2.getLabels();
fprintf('The two objects should have the same number of labels\n');
assertEqual(length(keys1), length(keys2));

function testSaveFieldMap(values) %#ok<INUSD,DEFNU>
fprintf('\nUnit tests for saveFieldMap static method of fieldMap\n');
fprintf('It should save a fieldMap object correctly\n');
fMap = fieldMap();
fName = tempname;
fieldMap.saveFieldMap(fName, fMap);
bT2 = fieldMap.loadFieldMap(fName);
assertTrue(isa(bT2, 'fieldMap'));

function testGetTags(values) %#ok<DEFNU>
% Unit test for fieldMap getTags method
fprintf('\nUnit tests for fieldMap getTags method\n');

fprintf('It should get the right tags for fields that exist \n');
fMap = findtags(values.data);
tags1 = fMap.getTags('type', 'RT');
assertEqual(length(tags1), 2);
tags2 = fMap.getTags('type', 'Trigger');
assertTrue(isempty(tags2));
tags3 = fMap.getTags('code', '1');
assertEqual(length(tags3), 2);

fprintf('It should not cause an error when field name doesn''t exist \n');
tags4 = fMap.getTags('banana', 'RT');
assertTrue(isempty(tags4));
fprintf('It should not cause an error when the field value doesn''t exist\n');
tags5 = fMap.getTags('type', 'banana');
assertTrue(isempty(tags5));

function testMergeXml(values) %#ok<INUSD,DEFNU>
% Unit test for fieldMap mergeXml static method
fprintf('\nUnit tests for mergeXml static method of fieldMap\n');

fprintf('It should merge XML when both tag sets are empty\n');
obj1 = fieldMap();
obj1.mergeXml('');
xml1 = obj1.getXml;
assertTrue(~isempty(xml1));
obj1.mergeXml(xml1);
%assertTrue(strcmpi(strtrim(obj1.getXml()), strtrim(xml1)));

function testValidateXml(values)  %#ok<DEFNU>
% Unit test for fieldMap validateXml static method
fprintf('\nUnit tests for valideXml static method of fieldMap\n');

fprintf('It should validate empty XML\n');
obj1 = fieldMap();
obj1.validateXml(values.xmlSchema, '');

fprintf('It should validate non-empty XML\n');
obj1 = fieldMap();
obj1.validateXml(values.xmlSchema, values.xml);

fprintf('It should validate invalid XML and throw an exception\n');
obj1 = fieldMap();
assertExceptionThrown(@() error(obj1.validateXml(values.xmlSchema, ...
    '<mismatchingtag1> invalid xml <mismatchingtag2>')), 'MATLAB:maxlhs');



