function test_suite = test_csvtags%#ok<STOUT>
initTestSuite;

function values = setup %#ok<STOUT,DEFNU>
% values.TestDirectory = 'H:\TagTestDirectories\TestDataRoot';
setup_tests;

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test


% function test_csvtagsEmpty(values)  %#ok<INUSD,DEFNU>
% % Unit test for csvtags function with empty directory
% fprintf('\nBe sure to edit setup_tests.m before running this test\n');
% fprintf('\nUnit tests for csvtags for empty directory\n');
% 
% 
% fprintf('It should work when there is an invalid directory---WARNING\n');
% [eTags2, fPaths2] = csvtags('--34', 'UseGui', false);
% assertTrue(isempty(fPaths2));
% assertTrue(isempty(eTags2));

function test_basic(values)  %#ok<DEFNU>
%Unit test for csvtags for basic arguments
fprintf('\nUnit tests for csvtags with no optional\n');

fprintf('It should work with only the filename as an argument\n');
[tMap1, headers1] = csvtags(values.efile2);
assertTrue(isa(tMap1, 'tagMap'));
assertEqual(length(headers1), 3);
codes1 = tMap1.getLabels();
assertEqual(length(codes1), 36);
values1 = tMap1.getValues();
assertEqual(length(values1), 36);
assertTrue(isfield(values1{1}, 'label'));
assertTrue(isfield(values1{1}, 'tags'));
assertTrue(isfield(values1{1}, 'description'));


fprintf('It should return an empty tagMap if the file has one line\n');
[tMap2, headers2] = csvtags(values.onerow);
assertTrue(isempty(tMap2.getLabels()));
assertEqual(length(headers2), 4);

function test_badfile(values)  %#ok<DEFNU>
%Unit test for csvtags for basic arguments
fprintf('\nUnit tests for csvtags with bad file name\n');
fprintf('It should throw an exception when the file doesn''t exist\n');
f = @() csvtags(values.badfile);
assertAltExceptionThrown(f, {'MATLAB:FileIO:InvalidFid'});

function test_arguments(values)  %#ok<DEFNU>
%Unit test for csvtags for basic arguments
fprintf('\nIt should give same answer when key columns specified explicitly\n');
[tMap1, headers1] = csvtags(values.efile2);
fprintf('It should work explicit event codes\n');
[tMap2, headers2] = csvtags(values.efile2,  'EventColumns', 1:3);
keys1 = tMap1.getLabels();
keys2 = tMap2.getLabels();
assertEqual(length(keys2), length(keys1));
assertEqual(length(headers2), length(headers1));
for k = 1:length(keys1)
    assertTrue(strcmpi(keys1{k}, keys2{k}));
end
for k = 1:length(headers1)
    assertTrue(strcmpi(tMap1.getField(), tMap1.getField()));
end

fprintf('It should give work when key and description columns are specified explicitly\n');
[tMap3, headers3] = ...
    csvtags(values.efile1, 'EventColumns', [1, 3, 5], 'DescriptionColumn', 8);
keys3 = tMap3.getLabels();
assertEqual(length(keys3), length(keys1));
assertEqual(length(headers3), 8);
for k = 1:length(keys1)
    assertTrue(strcmpi(keys1{k}, keys3{k}));
end
