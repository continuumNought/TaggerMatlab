function test_suite = test_tagcsv%#ok<STOUT>
initTestSuite;

function values = setup %#ok<STOUT,DEFNU>
% values.TestDirectory = 'H:\TagTestDirectories\TestDataRoot';
setup_tests;

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test


function test_tagcsvEmpty(values)   %#ok<DEFNU>
% Unit test for tagcsv function with empty directory
fprintf('\nBe sure to edit setup_tests.m before running this test\n');
fprintf('\nUnit tests for tagcsv for empty file\n');

fprintf('It should work when there is an empty file ---WARNING\n');
eTags1 = tagcsv(values.emptyfile, 'UseGui', false);
fprintf('It should work when there is an invalid ---WARNING\n');
eTags2 = tagcsv('--34', 'UseGui', false);
assertTrue(isempty(eTags2));

function test_basic(values)  %#ok<DEFNU>
%Unit test for tagcsv for basic stuff
fprintf('\nUnit tests for tagcsv with no GUI no write\n');

fprintf('It should work with only the filename as an argument\n');
fMap1 = tagcsv(values.efile2);
[events1, type1] = findcsvtags(values.efile2);
types = fMap1.getFields();
assertEqual(length(types), 1);
assertTrue(strcmpi(type1, types{1}));
% assertTrue(isa(events1, 'cell'));
% assertTrue(ischar(type1));
% assertEqual(length(events1), 36);
% assertTrue(isfield(events1{1}, 'label'));
% assertTrue(isfield(events1{1}, 'tags'));
% assertTrue(isfield(events1{1}, 'description'));
% fprintf('\nUnit tests for tagcsv with EEGLAB data\n');
% 
% fprintf('It should work for the EEGLAB data without any GUIs\n');
% thisDir = [values.testroot filesep values.EEGLAB];
% [fMap1, fPaths1] = tagcsv(thisDir, 'UseGui', false, 'SelectOption', false);
% fields1 = fMap1.getFields();
% assertEqual(length(fields1), 2);
% types1 = fMap1.getValues('type');
% assertEqual(length(types1), 2)
% position1 = fMap1.getValues('position');
% assertEqual(length(position1), 2)
% assertEqual(length(fPaths1), 3);
% 
% 
% fprintf('\n\nIt should work for the EEGLAB data with the only the options\n');
% fprintf('....REQUIRES USER INPUT\n');
% fprintf('PRESS the EXCLUDE BUTTON FOR TYPE AND TAG BUTTON FOR POSITION\n');
% [fMap2, fPaths2] = tagcsv(thisDir, 'UseGui', false, ...
%     'Synchronize', false, 'SelectOption', true);
% fields2 = fMap2.getFields();
% assertEqual(length(fields2), 1);
% assertTrue(strcmpi('position', fields2{1}));
% types2 = fMap2.getValues('type');
% assertTrue(isempty(types2));
% position2 = fMap2.getValues('position');
% assertEqual(length(position2), 2)
% assertEqual(length(fPaths2), 3);
% 
% fprintf('\n\nIt should work for the EEGLAB data with just the GUI\n');
% fprintf('....REQUIRES USER INPUT\n');
% fprintf('PRESS the SUBMIT BUTTON BOTH TIMES\n');
% [fMap3, fPaths3] = tagcsv(thisDir, 'UseGui', true, ...
%     'SelectOption', false, 'Synchronize', true);
% fields3 = fMap3.getFields();
% assertEqual(length(fields3), 2);
% types3 = fMap3.getValues('type');
% assertEqual(length(types3), 2);
% position3 = fMap3.getValues('position');
% assertEqual(length(position3), 2)
% assertEqual(length(fPaths3), 3);
% 
% fprintf('\n\nIt should work for the EEGLAB data with both options and GUI\n');
% fprintf('....REQUIRES USER INPUT\n');
% fprintf('PRESS the TAG BUTTON BOTH TIMES\n');
% [fMap4, fPaths4] = tagcsv(thisDir, 'UseGui', true, ...
%     'SelectOption', true, 'Synchronize', false);
% fields4 = fMap4.getFields();
% assertEqual(length(fields4), 2);
% types4 = fMap4.getValues('type');
% assertEqual(length(types4), 2);
% position4 = fMap4.getValues('position');
% assertEqual(length(position4), 2)
% assertEqual(length(fPaths4), 3);
% 
% 
% function test_tagcsvBCI2000(values)  %#ok<DEFNU>
% % Unit test for tagcsv for BCI2000 data
% fprintf('\n\nUnit tests for tagcsv for BCI2000\n');
% 
% fprintf('It should work for the BCI2000 data with both options and GUI\n');
% fprintf('....REQUIRES USER INPUT\n');
% fprintf('PRESS the TAG BUTTON ALWAYS\n');
% thisDir = [values.testroot filesep values.BCI2000dir];
% [fMap1, fPaths1] = tagcsv(thisDir, 'UseGui', true, ...
%     'SelectOption', true, 'Synchronize', false);
% fields1 = fMap1.getFields();
% assertEqual(length(fields1), 1);
% type1 = fMap1.getValues('type');
% assertEqual(length(type1), 17);
% assertEqual(length(fPaths1), 42);
% 
% 
% function test_tagcsvShooter(values)  %#ok<DEFNU>
% % Unit test for tagcsv with shooter data 
% fprintf('\n\nUnit tests for tagcsv with shooter data\n');
% 
% fprintf('It should work for the shooter data with both options and GUI\n');
% fprintf('....REQUIRES USER INPUT\n');
% fprintf('PRESS the TAG BUTTON EXCEPT EXCLUDE THE TRIAL\n');
% [fMap1, fPaths1] = tagcsv([values.testroot filesep values.shooterdir], ...
%     'UseGui', true, ...
%     'SelectOption', true, 'Synchronize', false);
% fields1 = fMap1.getFields();
% assertEqual(length(fields1), 9);
% type1 = fMap1.getValues('type');
% assertEqual(length(type1), 23);
% assertEqual(length(fPaths1), 16);
% 
