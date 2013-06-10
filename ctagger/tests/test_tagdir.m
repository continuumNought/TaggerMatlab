function test_suite = test_tagdir%#ok<STOUT>
initTestSuite;

function values = setup %#ok<DEFNU>
values.TestDirectory = 'H:\TagTestDirectories\TestDataRoot';
values.moreEvents = 'e5, e5 label, e5 description, /a/b/c; e6,e61,e6 des';
values.Attn = 'AttentionShiftSet';
values.BCI2000 = 'BCI2000Set';
values.EEGLAB = 'EEGLABSet';
values.Shooter = 'ShooterSet';

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test


function test_tagdirEmpty(values)  %#ok<INUSD,DEFNU>
% Unit test for tagdir function with empty directory
fprintf('\nUnit tests for tagdir for empty directory\n');

fprintf('It should work for an empty directory\n');
[eTags1, fPaths1] = tagdir('', 'UseGui', false);
assertTrue(isa(eTags1, 'fieldMap'));
assertTrue(isempty(fPaths1));
fields1 = eTags1.getFields();
assertTrue(isempty(fields1));

fprintf('It should work when there is an invalid directory\n');
[eTags2, fPaths2] = tagdir('--34', 'UseGui', false);
assertTrue(isa(eTags2, 'fieldMap'));
assertTrue(isempty(fPaths2));
fields2 = eTags1.getFields();
assertTrue(isempty(fields2));

function test_tagdirEEGLAB(values)  %#ok<DEFNU>
% Unit test for tagdir for EEGLAB sample data
% fprintf('\nUnit tests for tagdir with EEGLAB data\n');
% 
% fprintf('It should work for the EEGLAB data without any GUIs\n');
% thisDir = [values.TestDirectory filesep values.EEGLAB];
% [fMap1, fPaths1] = tagdir(thisDir, 'UseGui', false, 'SelectOption', false);
% fields1 = fMap1.getFields();
% assertEqual(length(fields1), 2);
% types1 = fMap1.getEvents('type');
% assertEqual(length(types1.getEvents), 2)
% position1 = fMap1.getEvents('position');
% assertEqual(length(position1.getEvents), 2)
% assertEqual(length(fPaths1), 3);
% 
% fprintf('It should work for the EEGLAB data with the only the options\n');
% fprintf('....REQUIRES USER INPUT\n');
% fprintf('PRESS the EXCLUDE BUTTON FOR TYPE AND TAG BUTTON FOR POSITION\n');
% [fMap2, fPaths2] = tagdir(thisDir, 'UseGui', false, ...
%     'Synchronize', false, 'SelectOption', true);
% fields2 = fMap2.getFields();
% assertEqual(length(fields2), 1);
% assertTrue(strcmpi('position', fields2{1}));
% types2 = fMap2.getEvents('type');
% assertTrue(isempty(types2));
% position2 = fMap2.getEvents('position');
% assertEqual(length(position2.getEvents), 2)
% assertEqual(length(fPaths2), 3);
% 
% fprintf('It should work for the EEGLAB data with just the GUI\n');
% fprintf('....REQUIRES USER INPUT\n');
% fprintf('PRESS the TAG BUTTON BOTH TIMES\n');
% [fMap3, fPaths3] = tagdir(thisDir, 'UseGui', true, ...
%     'SelectOption', false, 'Synchronize', true);
% fields3 = fMap3.getFields();
% assertEqual(length(fields3), 2);
% types3 = fMap3.getEvents('type');
% assertEqual(length(types3.getEvents), 2);
% position3 = fMap3.getEvents('position');
% assertEqual(length(position3.getEvents), 2)
% assertEqual(length(fPaths3), 3);
% 
% fprintf('It should work for the EEGLAB data with both options and GUI\n');
% fprintf('....REQUIRES USER INPUT\n');
% fprintf('PRESS the TAG BUTTON BOTH TIMES\n');
% [fMap4, fPaths4] = tagdir(thisDir, 'UseGui', true, ...
%     'SelectOption', true, 'Synchronize', false);
% fields4 = fMap4.getFields();
% assertEqual(length(fields4), 2);
% types4 = fMap4.getEvents('type');
% assertEqual(length(types4.getEvents), 2);
% position4 = fMap4.getEvents('position');
% assertEqual(length(position4.getEvents), 2)
% assertEqual(length(fPaths4), 3);


% function test_tagdirAttn(values)  %#ok<DEFNU>
% % Unit test for tagdir function with attention shift data
% fprintf('\nUnit tests for tagdir for attention shift data\n');
% 
% fprintf('It should work for the attention shift data without GUI\n');
% thisDir = [values.TestDirectory filesep values.Attn];
% [fMap1, fPaths1] = tagdir(thisDir, 'UseGui', false, 'SelectOption', false);
% attnFields1 = fMap1.getFields();
% assertEqual(length(attnFields1), 2);
% type1 = fMap1.getEvents('type');
% assertEqual(length(type1.getEvents()), 17);
% assertEqual(length(fPaths1), 6);
% 
% fprintf('It should work for the attention shift data with both options and GUI\n');
% fprintf('....REQUIRES USER INPUT\n');
% fprintf('PRESS the TAG BUTTON ALWAYS\n');
% [fMap2, fPaths2] = tagdir(thisDir, 'UseGui', true, ...
%     'SelectOption', true, 'Synchronize', false);
% attnFields2 = fMap2.getFields();
% assertEqual(length(attnFields2), 2);
% type2 = fMap2.getEvents('type');
% assertEqual(length(type2.getEvents()), 17);
% assertEqual(length(fPaths2), 6);


% function test_tagdirBCI2000(values)  %#ok<DEFNU>
% % Unit test for tagdir for BCI2000 data
% fprintf('\nUnit tests for tagdir for BCI2000\n');
% 
% fprintf('It should work for the BCI2000 data with both options and GUI\n');
% fprintf('....REQUIRES USER INPUT\n');
% fprintf('PRESS the TAG BUTTON ALWAYS\n');
% thisDir = [values.TestDirectory filesep values.BCI2000];
% [fMap1, fPaths1] = tagdir(thisDir, 'UseGui', true, ...
%     'SelectOption', true, 'Synchronize', false);
% fields1 = fMap1.getFields();
% assertEqual(length(fields1), 1);
% type1 = fMap1.getEvents('type');
% assertEqual(length(type1.getEvents()), 17);
% assertEqual(length(fPaths1), 42);


function test_tagdirShooter(values)  %#ok<DEFNU>
% Unit test for tagdir with shooter data 
fprintf('\nUnit tests for tagdir with shooter data\n');

fprintf('It should work for the shooter data with both options and GUI\n');
fprintf('....REQUIRES USER INPUT\n');
fprintf('PRESS the TAG BUTTON EXCEPT EXCLUDE THE TRIAL\n');
thisDir = [values.TestDirectory filesep values.Shooter];
[fMap1, fPaths1] = tagdir(thisDir, 'UseGui', true, ...
    'SelectOption', true, 'Synchronize', false);
fields1 = fMap1.getFields();
assertEqual(length(fields1), 9);
type1 = fMap1.getValues('type');
assertEqual(length(type1), 23);
assertEqual(length(fPaths1), 16);

