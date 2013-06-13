function test_suite = test_tagMap %#ok<STOUT>
initTestSuite;

function values = setup %#ok<DEFNU>
types = {'RT', 'Trigger', 'Missed'};
eStruct = struct('field', 'type',  'values', 'def');
tags = {'/Time-Locked Event/Stimulus/Visual/Shape/Ellipse/Circle', ...
        '/Time-Locked Event/Stimulus/Visual/Fixation Point', ...
        '/Time-Locked Event/Stimulus/Visual/Uniform Color/Black'};
sE = struct('label', types, 'description', types, 'tags', '');
sE(1).tags = tags;
eStruct.field = 'type';
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
[field1, values1] = tagMap.split(values.eJSON1, true);
fprintf('It should have the right field\n');
assertTrue(strcmpi(field1, 'type'));
fprintf('It should have the right number of values\n');
assertEqual(length(values1), 3);
fprintf('It should return the values in a structure\n');
assertTrue(isstruct(values1));

fprintf('It should split a valid text string \n');
testString = ['type;' values.eventList1];
[field2, values2] = tagMap.split(testString, false);
fprintf('It should have the right field\n');
assertTrue(strcmpi(field2, 'type'));
fprintf('It should have the right number of values\n');
assertEqual(length(values2), 2);
fprintf('It should return events in a structure when multiple values\n');
assertTrue(isstruct(values2));

function testValid(values) %#ok<DEFNU>
% Unit test for tagMap constructor valid JSON
fprintf('\nUnit tests for tagMap valid JSON constructor\n');

fprintf('It should create a valid object for a valid JSON events string\n');
[field1, values1] = tagMap.split(values.eJSON1, true);
assertTrue(strcmpi(field1, 'type'));
obj1 = tagMap();
assertTrue(isvalid(obj1));
fprintf('It should have the right number of values\n');
for k = 1:length(values1)
   obj1.addValue(values1(k));
end
valuesA = obj1.getValues();
assertEqual(length(valuesA), 3);
fprintf('It should create a valid object for a valid text string\n');
testString = ['type;' values.eventList1];
[field2, values2] = tagMap.split(testString, false);
assertTrue(strcmpi(field2, 'type'));
obj2 = tagMap();
assertTrue(isvalid(obj2));
fprintf('It should have the right number of values\n');
for k = 1:length(values2)
   obj2.addValue(values2(k));
end
valuesA = obj2.getValues();
assertEqual(length(valuesA), 2);

function testEmptyOrInvalid(values) %#ok<INUSD,DEFNU>
% Unit test for tagMap constructor empty or invalid
fprintf('\nUnit tests for tagMap empty or invalid JSON\n');

fprintf('It should create a tagMap when no parameters are used\n');
obj1 = tagMap();
assertTrue(isvalid(obj1));
fprintf('---the resulting structure should have the right fields\n');
eStruct1 = obj1.getStruct();
assertTrue(isstruct(eStruct1));
assertEqual(length(fieldnames(eStruct1)), 2);
assertElementsAlmostEqual(sum(isfield(eStruct1, { 'field', 'values'})), 2);
assertTrue(isempty(eStruct1.values));

function testMerge(values) %#ok<DEFNU>
% Unit test for tagMap merge method
fprintf('\nUnit tests for merge method of tagMap\n');

fprintf('It should merge correctly when code match is specified with matches found\n');
[f1, ev1] = tagMap.split([';' values.eventList1], false);
[f1a, bv1] = tagMap.split([';' values.baseList1], false);
assertTrue(isempty(f1));
assertTrue(isempty(f1a));
e1 = tagMap();
for k = 1:length(ev1)
   e1.addValue(ev1(k));
end
b1 = tagMap();
for k = 1:length(bv1)
   b1.addValue(bv1(k));
end
e1.merge(b1, 'OnlyTags', false);
eValues = e1.getValues();
assertEqual(length(eValues), 2);
value1 = e1.getValue('Trigger');
assertTrue(~isempty(value1));
fprintf('It should correctly merge tags when value labels match\n');
assertEqual(length(value1.tags), 3);
fprintf('It should have not merge values when argument is empty\n');
e1.merge('', 'OnlyTags', false);
eValues = e1.getValues();
assertEqual(length(eValues), 2);
e1.merge('', 'Merge', false);
eValues = e1.getValues();
assertEqual(length(eValues), 2);
fprintf('It should not include extra values if OnlyTags is true\n');
[f3, bv3] = tagMap.split([';' values.baseList3], false);
assertTrue(isempty(f3));
b3 = tagMap();
for k = 1:length(bv3)
   b3.addValue(bv3(k));
end
e1.merge(b3, 'OnlyTags', false);
eValues = e1.getValues();
assertEqual(length(eValues), 2);
fprintf('It should include extra events if OnlyTags is false\n');
e1.merge(b3, 'Merge', false);
eValues = e1.getValues();
assertEqual(length(eValues), 3);

fprintf('It should work when PreservePrefix is true\n');
[f2, ev2] = tagMap.split([';' values.eventList1], false);
assertTrue(isempty(f2));
eT2 = tagMap();
for k = 1:length(ev2)
   eT2.addValue(ev2(k));
end
eT2.merge(b1, 'OnlyTags', true);
eValues = eT2.getValues();
assertEqual(length(eValues), 2);
event2 = eT2.getValue('Trigger');
assertTrue(~isempty(event2));
fprintf('It should correctly merge tags when value labels match\n');
assertEqual(length(event2.tags), 4);

fprintf('It should not merge the values when fields don''t match\n');
[f3, ev3] = tagMap.split([';' values.eventList1], false);
assertTrue(isempty(f3));
eT3 = tagMap();
for k = 1:length(ev3)
   eT3.addValue(ev3(k));
end
assertEqual(length(eT3.getValues()), 2);
assertTrue(strcmpi(eT3.getField(), 'type'));
[f4, ev4] = tagMap.split([';' values.baseList3], false);
assertTrue(isempty(f4));
eT4 = tagMap();
for k = 1:length(ev4)
   eT4.addValue(ev4(k));
end
assertEqual(length(eT4.getValues()), 2);
assertTrue(strcmpi(eT4.getField(), 'type'));
eT3.merge(eT4, 'Merge', false);
assertEqual(length(eT3.getValues()), 3);
eT3a = tagMap();
for k = 1:length(ev3)
   eT3a.addValue(ev3(k));
end
eT4a = tagMap('Field', 'balony');
for k = 1:length(ev4)
   eT4a.addValue(ev4(k));
end
eT3a.merge(eT4a, 'Merge', false);
assertEqual(length(eT3a.getValues()), 2);

function testGetText(values) %#ok<DEFNU>
% Unit test for tagMap mergeTagMap method
fprintf('\nUnit tests for getText method of tagMap\n');
fprintf('The text from an object created in text is valid\n');
[f1, e1] = tagMap.split([';' values.eventList1], false);
assertTrue(isempty(f1));
eT1 = tagMap();
for k = 1:length(e1)
   eT1.addValue(e1(k));
end
theText = eT1.getText();
[f2, e2] = tagMap.split(theText, false);
assertTrue(isa(e2, 'struct'));
assertTrue(strcmpi(f2, 'type'));
eT2 = tagMap();
for k = 1:length(e2)
   eT2.addValue(e2(k));
end
assert(isvalid(eT2));
theJson = eT2.getJson();
x1 = tagMap.json2Mat(theJson);
fprintf('The text from an object created from text is valid\n');
assertTrue(isstruct(x1));
valuesA = x1.values;
assertEqual(length(valuesA), 2);
assertEqual(length(valuesA(1).tags) + length(valuesA(2).tags), 2);

function testCreateEvent(values) %#ok<INUSD,DEFNU>
% Unit test for tagMap createValue static method
fprintf('\nUnit tests for createValue static method of tagMap\n');

fprintf('It should throw an exception for no arguments\n');
f = @() tagMap.createValue();
assertAltExceptionThrown(f, {'MATLAB:inputArgUndefined', 'MATLAB:minrhs'});

fprintf('It should create a valid structure when one argument invalid\n');
event = tagMap.createValue('3', 'event 3', {'a', 'b', 'c'});
assertTrue(isstruct(event));
assertTrue(tagMap.validateValue(event));

function testText2Event(values) %#ok<INUSD,DEFNU>
% Unit test for tagMap .parseCommaEvent static method
fprintf('\nUnit tests for parseCommaEvent static method of tagMap\n');

fprintf('It should return empty values when input is empty\n');
theStruct = tagMap.text2Value('');

assertTrue(isempty(theStruct.label));
assertTrue(isempty(theStruct.description));
assertTrue(isempty(theStruct.tags));
fprintf('It should return filled values when there is a valid event string\n');
theStruct1 = tagMap.text2Value('Trigger,code 2,/my/tag1, /my/tag2');
assertTrue(strcmpi(theStruct1.label, 'Trigger'));
assertTrue(strcmpi(theStruct1.description, 'code 2'));
assertEqual(length(theStruct1.tags), 2);
fprintf('It should return filled values when there are no tags\n');
theStruct2 = tagMap.text2Value('Trigger,code 1,');
assertEqual(length(theStruct2), 1);
% fprintf('The tags should be empty after reformatting\n');
% [rEvent2, valid2] = tagMap.reformatValue(theStruct2);
% assertTrue(valid2);
% assertTrue(isempty(rEvent2.tags));
% fprintf('It should return filled values when there is 1 tag\n');
% theStruct3 = tagMap.text2Value('Trigger,code 1,/my/tag1,');
% assertEqual(length(theStruct3), 1);
% [rEvent3, valid3] = tagMap.reformatValue(theStruct3);
% assertTrue(valid3);
% assertTrue(ischar(rEvent3.tags));
fprintf('It should return the correct number of tags when there are blank tags\n');
theStruct4 = tagMap.text2Value('Trigger,code 2,  , /my/tag2');
assertTrue(strcmpi(theStruct4.label, 'trigger'));
assertEqual(length(theStruct4.tags), 1);
theStruct5 = tagMap.text2Value('Trigger,code 2,  , ');
assertTrue(strcmpi(theStruct5.label, 'trigger'));
assertTrue(isempty(theStruct5.tags));

% function testReformatEvent(values) %#ok<INUSD,DEFNU>
% % Unit test for tagMap reformatValue static method
% fprintf('\nUnit tests for reformatValue static method of tagMap\n');
% 
% fprintf('It should be not be valid for empty events\n');
% [event, valid] = tagMap.reformatValue(''); %#ok<ASGLU>
% assertTrue(~valid);
% fprintf('It should be not be valid for blank label\n');
% event2 = struct('label', '  ', 'description', '', 'Tags', '');
% [events2a, valid2] = tagMap.reformatValue(event2); %#ok<ASGLU>
% assertTrue(~valid2);

function testValue2Json(values) %#ok<DEFNU>
% Unit test for tagMap static value2Json method
fprintf('\nUnit tests for value2Json static method of tagMap\n');
fprintf('It should throw an exception if the event is empty\n');
f = @() tagMap.value2Json(values.emptyValue);
assertAltExceptionThrown(f, {'MATLAB:nonStrucReference'});
fprintf('It should throw an exception if some fields are missing\n');
f = @() tagMap.value2Json(values.valueMissingFields);
assertAltExceptionThrown(f, {'MATLAB:nonExistentField'});
fprintf('It should work if the tags field is empty\n');
tagsEmpty = tagMap.value2Json(values.valueEmptyTags);
theStruct = loadjson(tagsEmpty);
savejson('', theStruct);
fprintf('It should work for one value\n');
oneValue = tagMap.value2Json(values.oneValue);
theStruct = loadjson(oneValue);
savejson('', theStruct);

function testValue2Text(values) %#ok<DEFNU>
fprintf('\nUnit tests for value2Text static method of tagMap\n');
fprintf('It should throw an exception if the event is empty\n');
f = @() tagMap.value2Text(values.emptyValue);
assertAltExceptionThrown(f, {'MATLAB:nonStrucReference'});
fprintf('It should throw an exception if some fields are missing\n');
f = @() tagMap.value2Text(values.eventMissingFields);
assertAltExceptionThrown(f, {'MATLAB:nonExistentField'});
fprintf('It should work if the tags field is empty\n');
tagsEmpty = tagMap.value2Text(values.valueEmptyTags);
theStruct = tagMap.text2Value(tagsEmpty);
savejson('', theStruct);
fprintf('It should work for one event\n');
oneValue = tagMap.value2Text(values.oneValue);
theStruct = tagMap.text2Value(oneValue);
savejson('', theStruct);

function testValues2Json(values) %#ok<INUSD,DEFNU>
fprintf('\nUnit tests for values2Json static method of tagMap\n');
fprintf('It should work if the values cell array is empty\n');
eText = tagMap.values2Json('');
theStruct = tagMap.json2Values(eText);
assertTrue(isempty(theStruct));


function testText2Values(values) %#ok<DEFNU>
fprintf('\nUnit tests for text2Values static method of tagMap\n');
fprintf('It should work if the string is empty\n');
eStruct1 = tagMap.text2Value(values.oneType);
assertTrue(isstruct(eStruct1));
eStruct2 = tagMap.text2Values(values.oneType);
assertTrue(isstruct(eStruct2));
assertEqual(length(eStruct2), 1);
eStruct3 = tagMap.text2Values(values.typeValues);
assertTrue(isstruct(eStruct3));
assertEqual(length(eStruct3), 3);
assertEqual(length(eStruct3(1).tags), 2);
assertEqual(length(eStruct3(2).tags), 0);
assertEqual(length(eStruct3(3).tags), 0);

function testText2Mat(values) %#ok<INUSD,DEFNU>
fprintf('\nUnit tests for text2Values static method of tagMap\n');
fprintf('It should work if the string is empty\n');

function testClone(values) %#ok<DEFNU>
fprintf('\nUnit tests for clone method of tagMap\n');
fprintf('It should correctly clone a tagMap object\n');
[field1, values1] = tagMap.split(values.eJSON1, true);
obj1 = tagMap();
for k = 1:length(values1)
   obj1.addValue(values1(k));
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

function testGetJsonEvents(values) %#ok<DEFNU>
fprintf('\nUnit tests for getJson method of tagMap\n');
fprintf('It should correctly retrieve the values as a  tagMap object\n');
[field1, values1] = tagMap.split(values.eJSON1, true); %#ok<ASGLU>
obj1 = tagMap();
for k = 1:length(values1)
   obj1.addValue(values1(k));
end
string1 = obj1.getJsonValues();
assertTrue(ischar(string1));
