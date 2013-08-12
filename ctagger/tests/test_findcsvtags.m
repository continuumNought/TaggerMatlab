function test_suite = test_findcsvtags%#ok<STOUT>
initTestSuite;

function values = setup %#ok<STOUT,DEFNU>
% values.TestDirectory = 'H:\TagTestDirectories\TestDataRoot';
setup_tests;

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test

function test_basic(values)  %#ok<DEFNU>
%Unit test for findcsvtags for basic arguments
fprintf('\nUnit tests for findcsvtags with no optional\n');

fprintf('It should work with only the filename as an argument\n');
[eValues1, events1, type1] = findcsvtags(values.efile2);
assertTrue(isa(events1, 'cell'));
assertTrue(ischar(type1));
assertEqual(length(eValues1), 37);
assertTrue(iscell(eValues1));
assertEqual(length(events1), 36);
assertTrue(isfield(events1{1}, 'label'));
assertTrue(isfield(events1{1}, 'tags'));
assertTrue(isfield(events1{1}, 'description'));


fprintf('It should return an empty tagMap if the file has one line\n');
[eValues2, events2, type2] = findcsvtags(values.onerow);
assertEqual(length(eValues2), 1);
assertTrue(iscell(eValues2));
assertTrue(isempty(events2));
assertFalse(isempty(type2));

function test_badfile(values)  %#ok<DEFNU>
%Unit test for findcsvtags for basic arguments
fprintf('\nUnit tests for findcsvtags with bad file name\n');
fprintf('It should not throw an exception when the file doesn''t exist\n');
[eValues, events, type] = findcsvtags(values.badfile);
assertTrue(isempty(eValues));
assertTrue(isempty(events));
assertTrue(isempty(type));

function test_arguments(values)  %#ok<DEFNU>
%Unit test for findcsvtags for basic arguments
fprintf('\nIt should give same answer when key columns specified explicitly\n');
[eValues1, events1, type1] = findcsvtags(values.efile2);
fprintf('It should work explicit event code columns\n');
[eValues2, events2, type2] = findcsvtags(values.efile2,  'EventColumns', 1:3);
assertEqual(length(events2), length(events1));
assertEqual(length(eValues1), length(eValues2));
for k = 1:length(events1)
    assertTrue(strcmpi(events1{k}.label, events2{k}.label));
end
assertTrue(strcmpi(type1, type2));

fprintf('It should give work when key and description columns are specified explicitly\n');
[eValues3, events3, type3] = ...
    findcsvtags(values.efile1, 'EventColumns', [1, 3, 5], 'DescriptionColumn', 8);
assertEqual(length(events3), length(events1));
assertEqual(length(eValues1), length(eValues3));
for k = 1:length(events1)
    assertTrue(strcmpi(events1{k}.label, events3{k}.label));
end
assertTrue(strcmpi(type1, type3));
