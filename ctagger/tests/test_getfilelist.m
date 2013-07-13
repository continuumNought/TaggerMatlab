function test_suite = test_getfilelist %#ok<STOUT>
initTestSuite;

function values = setup %#ok<DEFNU>
values.bci = 'H:\BCIProcessing\BCI2000Set';
values.TestDirectories = 'H:\TagTestDirectories';

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test

function testValidTree(values) %#ok<DEFNU>
% Unit test for getFileList
fprintf('\nUnit tests for getfilelist\n');

fprintf('It should get all the files when no extension is given\n');
fList1 = getfilelist(values.bci);
assertEqual(length(fList1), 1526);

fprintf('It should get all the files when an empty extension is given\n');
fList2 = getfilelist(values.bci);
assertEqual(length(fList2), 1526);

fprintf('It should get all the files when a .set extension is given\n');
fList3 = getfilelist(values.bci, '.set');
assertEqual(length(fList3), 1526);
fprintf('It should get no files files when a .txt extension is given\n');
fList3 = getfilelist(values.bci, '.txt');
assertEqual(length(fList3), 0);
fprintf('It should not traverse subdirectories when third argument false\n');
fList4 = getfilelist(values.bci, '.set', false);
assertEqual(length(fList4), 0);
testDir = [values.TestDirectories filesep 'TestDataRoot'];
fList5 = getfilelist(testDir, '.set', false);
assertEqual(length(fList5), 0);
fprintf('It should traverse subdirectories when third argument true\n');
fList6= getfilelist(values.bci, '.set', true);
assertEqual(length(fList6), 1526);

testDir = [values.TestDirectories filesep 'TestDataRoot'];
fList7 = getfilelist(testDir, '.set', true);
assertEqual(length(fList7), 67);