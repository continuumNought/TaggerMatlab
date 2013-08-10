function test_suite = test_getcsv%#ok<STOUT>
initTestSuite;

function values = setup %#ok<STOUT,DEFNU>
% values.TestDirectory = 'H:\TagTestDirectories\TestDataRoot';
setup_tests;

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test


% function test_getcsvEmpty(values)  %#ok<INUSD,DEFNU>
% % Unit test for getcsv function with empty directory
% fprintf('\nBe sure to edit setup_tests.m before running this test\n');
% fprintf('\nUnit tests for getcsv for empty directory\n');
% 
% 
% fprintf('It should work when there is an invalid directory---WARNING\n');
% [eTags2, fPaths2] = getcsv('--34', 'UseGui', false);
% assertTrue(isempty(fPaths2));
% assertTrue(isempty(eTags2));

function test_basic(values)  %#ok<DEFNU>
%Unit test for getcsv for basic arguments
fprintf('\nUnit tests for getcsv with no optional\n');

fprintf('It should work with only the filename as an argument\n');
[codes, headers, descriptions] = getcsv(values.efile2);
assertEqual(length(descriptions), 39);
assertEqual(length(codes), 39);
assertEqual(length(headers), 3);
assertEqual(length(codes), length(descriptions));

fprintf('It should return only the header if the file has one line\n');
[codes, headers, descriptions] = getcsv(values.onerow);
assertTrue(isempty(codes));
assertTrue(isempty(descriptions));
assertEqual(length(headers), 4);

function test_badfile(values)  %#ok<DEFNU>
%Unit test for getcsv for basic arguments
fprintf('\nUnit tests for getcsv with bad file name\n');
fprintf('It should throw an exception when the file doesn''t exist\n');
f = @() getcsv(values.badfile);
assertAltExceptionThrown(f, {'MATLAB:FileIO:InvalidFid'});

function test_arguments(values)  %#ok<DEFNU>
%Unit test for getcsv for basic arguments
fprintf('\nUnit tests for getcsv with no optional\n');

fprintf('It should give same answer when key columns specified explicitly\n');
[codes1, headers1, descriptions1] = getcsv(values.efile2);
fprintf('It should work with a few codes and no descriptions\n');
[codes2, headers2, descriptions2] = ...
    getcsv(values.efile2,  'EventColumns', 1:3);
assertEqual(length(descriptions2), length(descriptions1));
assertEqual(length(codes2), length(codes1));
assertEqual(length(headers2), length(headers1));
assertEqual(length(descriptions2), length(descriptions1));
for k = 1:length(codes1)
    assertTrue(strcmpi(codes1{k}, codes2{k}));
    assertTrue(strcmpi(descriptions1{k}, descriptions2{k}));
end
for k = 1:length(headers1)
    assertTrue(strcmpi(headers1{k}, headers2{k}));
end

fprintf('It should give work when key and description columns are specified explicitly\n');
[codes3, headers3, descriptions3] = ...
    getcsv(values.efile1, 'EventColumns', [1, 3, 5], 'DescriptionColumn', 8);
assertEqual(length(descriptions3), 39);
assertEqual(length(codes3), 39);
assertEqual(length(headers3), 8);
assertEqual(length(codes3), length(descriptions3));

for k = 1:length(codes1)
    assertTrue(strcmpi(codes1{k}, codes3{k}));
end
