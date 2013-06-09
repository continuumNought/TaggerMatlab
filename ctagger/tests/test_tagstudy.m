function test_suite = test_tagstudy%#ok<STOUT>
initTestSuite;

function values = setup %#ok<DEFNU>
% Function executed after each test
values.TestDirectory = 'H:\TagTestDirectories\Study\5subjects';
values.StudyName = 'n400clustedit.study';

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test


function test_tagdirEmpty(values)  %#ok<INUSD,DEFNU>
% Unit test for tagdir function with empty directory
fprintf('\nUnit tests for tagdir for empty directory\n');

fprintf('It should work for an empty directory\n');
[eTags1, fPaths1, excluded1] = tagstudy('', 'UseGui', false);
assertTrue(isa(eTags1, 'fieldMap'));
assertTrue(isempty(fPaths1));
fields1 = eTags1.getFields();
assertTrue(isempty(fields1));

fprintf('It should work when there is an invalid directory\n');
[eTags2, fPaths2, excluded2] = tagstudy('--34', 'UseGui', false);
assertTrue(isa(eTags2, 'fieldMap'));
assertTrue(isempty(fPaths2));
fields2 = eTags1.getFields();
assertTrue(isempty(fields2));


function test_tagValidStudy(values)  %#ok<DEFNU>
% Unit test for tagstudy with a valid study directory
fprintf('\nUnit tests for tagstudy valid\n');

fprintf('It should work for the shooter data with both options and GUI\n');
fprintf('....REQUIRES USER INPUT\n');
fprintf('PRESS the TAG BUTTON EXCEPT EXCLUDE THE TRIAL\n');
thisStudy = [values.TestDirectory filesep values.StudyName];
[fMap1, fPaths1, excluded1] = tagstudy(thisStudy, 'UseGui', false, ...
    'SelectOption', false);
fields1 = fMap1.getFields();
assertEqual(length(fields1), 9);
type1 = fMap1.getValues('type');
assertEqual(length(type1), 23);
assertEqual(length(fPaths1), 16);

