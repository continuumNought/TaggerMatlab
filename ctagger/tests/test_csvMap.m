function test_suite = test_csvMap%#ok<STOUT>
initTestSuite;

function values = setup %#ok<STOUT,DEFNU>
setup_tests;

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test

function test_constructor(values)  %#ok<DEFNU>
% Unit test for csvMap for constructor
fprintf('\nUnit tests for csvMap with no optional\n');

fprintf('It should work with only the filename as an argument\n');
obj1 = csvMap(values.efile2);
eHeader1 = obj1.getHeader(); 
eValues1 = obj1.getValues();
eLabels1 = obj1.getLabels();
events1 = obj1.getEvents();
type1 = obj1.getType();
assertEqual(length(eHeader1), 3);
assertTrue(iscell(eHeader1));
assertEqual(length(eValues1), 37);
assertTrue(iscell(eValues1));
assertEqual(length(eLabels1), 36);
assertTrue(iscell(eLabels1));
assertTrue(iscell(events1));
assertEqual(length(events1), 36);
assertTrue(isfield(events1{1}, 'label'));
assertTrue(isfield(events1{1}, 'tags'));
assertTrue(isfield(events1{1}, 'description'));
assertTrue(ischar(type1));

fprintf('It should return an empty tagMap if the file has one line\n');
obj2 = csvMap(values.onerow);
eHeader2 = obj2.getHeader(); 
eValues2 = obj2.getValues();
eLabels2 = obj2.getLabels();
events2 = obj2.getEvents();
type2 = obj2.getType();
assertEqual(length(eHeader2), 4);
assertTrue(iscell(eHeader2));
assertEqual(length(eValues2), 1);
assertTrue(iscell(eValues2));
assertTrue(isempty(eLabels2));
assertTrue(isempty(events2));
assertFalse(isempty(type2));

function test_badfile(values)  %#ok<DEFNU>
% Unit test for csvMap for bad file
fprintf('\nUnit tests for csvMap with bad file name\n');
fprintf('It should not throw an exception when the file doesn''t exist\n');
obj = csvMap(values.badfile);
eHeader = obj.getHeader(); 
eValues = obj.getValues();
eLabels = obj.getLabels();
events = obj.getEvents();
type = obj.getType();
assertTrue(isempty(eHeader));
assertTrue(isempty(eValues));
assertTrue(isempty(eLabels));
assertTrue(isempty(events));
assertTrue(isempty(type));

function test_arguments(values)  %#ok<DEFNU>
% Unit test for csvMap for basic arguments
fprintf('\nIt should give the same answer when key columns specified explicitly\n');
obj1 = csvMap(values.efile2);
eHeader1 = obj1.getHeader(); 
eValues1 = obj1.getValues();
eLabels1 = obj1.getLabels();
events1 = obj1.getEvents();
type1 = obj1.getType();
fprintf('It should work explicitly with event code columns\n');
obj2 = csvMap(values.efile2,  'EventColumns', 1:3);
eHeader2 = obj2.getHeader(); 
eValues2 = obj2.getValues();
eLabels2 = obj2.getLabels();
events2 = obj2.getEvents();
type2 = obj2.getType();
assertEqual(length(eHeader1), length(eHeader2));
assertEqual(length(eValues1), length(eValues2));
assertEqual(length(eLabels1), length(eLabels2));
assertEqual(length(events2), length(events1));
for k = 1:length(events1)
    assertTrue(strcmpi(events1{k}.label, events2{k}.label));
    assertEqual(obj1.getValue(events1{k}.label), ...
        obj2.getValue(events2{k}.label));
end
assertTrue(strcmpi(type1, type2));

fprintf('It should work when key and description columns are specified explicitly\n');
obj3 = ...
    csvMap(values.efile1, 'EventColumns', [1, 3, 5], 'DescriptionColumn', 8);
eHeader3 = obj3.getHeader(); 
eValues3 = obj3.getValues();
eLabels3 = obj3.getLabels();
events3 = obj3.getEvents();
type3 = obj3.getType();
assertFalse(isequal(length(eHeader1), length(eHeader3)));
assertEqual(length(eValues1), length(eValues3));
assertEqual(length(eLabels1), length(eLabels3));
assertEqual(length(events1), length(events3));
for k = 1:length(events1)
    assertTrue(strcmpi(events1{k}.label, events3{k}.label));
    assertEqual(obj1.getValue(events1{k}.label), ...
        obj3.getValue(events2{k}.label));
end
assertTrue(strcmpi(type1, type3));