function test_suite = test_splitcsv%#ok<STOUT>
initTestSuite;

function values = setup %#ok<STOUT,DEFNU>
% values.TestDirectory = 'H:\TagTestDirectories\TestDataRoot';
setup_tests;

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test

function test_basic(values)  %#ok<DEFNU>
%Unit test for splitcsv for basic arguments
fprintf('\nUnit tests for splitcsv\n');

fprintf('It should with an ordinary CSV file\n');
outValues1 = splitcsv(values.efile2);
assertEqual(length(outValues1), 37);
for k = 1:length(outValues1)
    x = outValues1{k};
    assertTrue(iscellstr(x));
    assertEqual(length(x), 3);
end

fprintf('It should when there is one row only\n');
outValues2 = splitcsv(values.onerow);
assertEqual(length(outValues2), 1);
assertEqual(length(outValues2{1}), 4);

fprintf('It should work for an empty file\n');
outValues3 = splitcsv(values.emptyfile);
assertTrue(isempty(outValues3));

fprintf('It should not throw an exception for a bad file\n');
outValues4 = splitcsv(values.badfile);
assertTrue(isempty(outValues4));


