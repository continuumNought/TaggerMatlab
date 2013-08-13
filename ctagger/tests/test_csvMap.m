function test_suite = test_csvMap%#ok<STOUT>
initTestSuite;

function values = setup %#ok<STOUT,DEFNU>
% values.TestDirectory = 'H:\TagTestDirectories\TestDataRoot';
setup_tests;

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test

function test_constructor(values)  %#ok<DEFNU>
%Unit test for csvMap for constructor
fprintf('\nUnit tests for csvMap with no optional\n');

fprintf('It should work with only the filename as an argument\n');
obj1 = csvMap(values.efile2);
eValues1 = obj1.getValues();
events1 = obj1.getEvents();
type1 = obj1.getType();
assertTrue(isa(events1, 'cell'));
assertTrue(ischar(type1));
assertEqual(length(eValues1), 37);
assertTrue(iscell(eValues1));
assertEqual(length(events1), 36);
assertTrue(isfield(events1{1}, 'label'));
assertTrue(isfield(events1{1}, 'tags'));
assertTrue(isfield(events1{1}, 'description'));

fprintf('It should return an empty tagMap if the file has one line\n');
obj2 = csvMap(values.onerow);
eValues2 = obj2.getValues();
events2 = obj2.getEvents();
type2 = obj2.getType();
assertEqual(length(eValues2), 1);
assertTrue(iscell(eValues2));
assertTrue(isempty(events2));
assertFalse(isempty(type2));

function test_badfile(values)  %#ok<DEFNU>
%Unit test for csvMap for basic arguments
fprintf('\nUnit tests for csvMap with bad file name\n');
fprintf('It should not throw an exception when the file doesn''t exist\n');
obj = csvMap(values.badfile);
eValues = obj.getValues();
events = obj.getEvents();
type = obj.getType();
assertTrue(isempty(eValues));
assertTrue(isempty(events));
assertTrue(isempty(type));

function test_arguments(values)  %#ok<DEFNU>
%Unit test for csvMap for basic arguments
fprintf('\nIt should give same answer when key columns specified explicitly\n');
obj1 = csvMap(values.efile2);
eValues1 = obj1.getValues();
events1 = obj1.getEvents();
type1 = obj1.getType();
fprintf('It should work explicit event code columns\n');
obj2 = csvMap(values.efile2,  'EventColumns', 1:3);
eValues2 = obj2.getValues();
events2 = obj2.getEvents();
type2 = obj2.getType();
assertEqual(length(events2), length(events1));
assertEqual(length(eValues1), length(eValues2));
for k = 1:length(events1)
    assertTrue(strcmpi(events1{k}.label, events2{k}.label));
end
assertTrue(strcmpi(type1, type2));

fprintf('It should give work when key and description columns are specified explicitly\n');
obj3 = ...
    csvMap(values.efile1, 'EventColumns', [1, 3, 5], 'DescriptionColumn', 8);
eValues3 = obj3.getValues();
events3 = obj3.getEvents();
type3 = obj3.getType();
assertEqual(length(events3), length(events1));
assertEqual(length(eValues1), length(eValues3));
for k = 1:length(events1)
    assertTrue(strcmpi(events1{k}.label, events3{k}.label));
end
assertTrue(strcmpi(type1, type3));

function test_getEvents(values)
%Unit test for csvMap for basic arguments
fprintf('\nIt should give same answer when key columns specified explicitly\n');
