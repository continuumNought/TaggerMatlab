function test_suite = test_getevents%#ok<STOUT>
initTestSuite;

function values = setup %#ok<STOUT,DEFNU>
% values.TestDirectory = 'H:\TagTestDirectories\TestDataRoot';
setup_tests;

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test


% function test_geteventsEmpty(values)  %#ok<INUSD,DEFNU>
% % Unit test for getevents function with empty directory
% fprintf('\nBe sure to edit setup_tests.m before running this test\n');
% fprintf('\nUnit tests for getevents for empty directory\n');
% 
% 
% fprintf('It should work when there is an invalid directory---WARNING\n');
% [eTags2, fPaths2] = getevents('--34', 'UseGui', false);
% assertTrue(isempty(fPaths2));
% assertTrue(isempty(eTags2));

function test_basic(values)  %#ok<DEFNU>
%Unit test for getevents for basic arguments
fprintf('\nUnit tests for getevents with no optional\n');

fprintf('It should work with only the filename as an argument\n');
[keys, headers, descriptions] = getevents(values.efile1);
assertEqual(length(descriptions), 39);
assertEqual(length(keys), 39);
assertEqual(length(headers), 3);



