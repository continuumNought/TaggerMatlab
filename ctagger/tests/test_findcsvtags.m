function test_suite = test_findcsvtags%#ok<STOUT>
initTestSuite;

function values = setup %#ok<STOUT,DEFNU>
% values.TestDirectory = 'H:\TagTestDirectories\TestDataRoot';
setup_tests;

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test


% function test_findcsvtagsEmpty(values)  %#ok<INUSD,DEFNU>
% % Unit test for findcsvtags function with empty directory
% fprintf('\nBe sure to edit setup_tests.m before running this test\n');
% fprintf('\nUnit tests for findcsvtags for empty directory\n');
% 
% 
% fprintf('It should work when there is an invalid directory---WARNING\n');
% [eTags2, fPaths2] = findcsvtags('--34', 'UseGui', false);
% assertTrue(isempty(fPaths2));
% assertTrue(isempty(eTags2));

function test_basic(values)  %#ok<DEFNU>
%Unit test for findcsvtags for basic arguments
fprintf('\nUnit tests for findcsvtags with no optional\n');

fprintf('It should work with only the filename as an argument\n');
[events1, type1] = findcsvtags(values.efile2);
assertTrue(isa(events1, 'cell'));
assertTrue(ischar(type1));
assertEqual(length(events1), 36);
assertTrue(isfield(events1{1}, 'label'));
assertTrue(isfield(events1{1}, 'tags'));
assertTrue(isfield(events1{1}, 'description'));


fprintf('It should return an empty tagMap if the file has one line\n');
[events2, type2] = findcsvtags(values.onerow);
assertTrue(isempty(events2));
assertFalse(isempty(type2));

function test_badfile(values)  %#ok<DEFNU>
%Unit test for findcsvtags for basic arguments
fprintf('\nUnit tests for findcsvtags with bad file name\n');
fprintf('It should not throw an exception when the file doesn''t exist\n');
[events, type] = findcsvtags(values.badfile);
assertTrue(isempty(events));
assertTrue(isempty(type));

function test_arguments(values)  %#ok<DEFNU>
%Unit test for findcsvtags for basic arguments
fprintf('\nIt should give same answer when key columns specified explicitly\n');
[events1, type1] = findcsvtags(values.efile2);
fprintf('It should work explicit event codes\n');
[events2, type2] = findcsvtags(values.efile2,  'EventColumns', 1:3);
assertEqual(length(events2), length(events1));
for k = 1:length(events1)
    assertTrue(strcmpi(events1{k}.label, events2{k}.label));
end
assertTrue(strcmpi(type1, type2));

fprintf('It should give work when key and description columns are specified explicitly\n');
[events3, type3] = ...
    findcsvtags(values.efile1, 'EventColumns', [1, 3, 5], 'DescriptionColumn', 8);
assertEqual(length(events3), length(events1));
for k = 1:length(events1)
    assertTrue(strcmpi(events1{k}.label, events3{k}.label));
end
assertTrue(strcmpi(type1, type3));
