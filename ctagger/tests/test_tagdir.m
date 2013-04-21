function test_suite = test_tagdir%#ok<STOUT>
initTestSuite;

function values = setup %#ok<DEFNU>
  values = '';
codes = {'1', '2', '3'};
types = {'RT', 'Trigger', 'Missed'};
eStruct = struct('hedXML', '', 'events', 'def');
tags = {'/Time-Locked Event/Stimulus/Visual/Shape/Ellipse/Circle', ...
        '/Time-Locked Event/Stimulus/Visual/Fixation Point', ...
        '/Time-Locked Event/Stimulus/Visual/Uniform Color/Black'};
sE = struct('code', codes, 'label', types, 'description', types, 'tags', '');
sE(1).tags = tags;
eStruct.events = sE;
eJSON1 = savejson('', eStruct);
values.eStruct1 = eStruct;
values.eJSON1 = eJSON1;
load EEGEpoch.mat;
values.EEGEpoch = EEGEpoch;
values.TestDirectory = 'H:\TagTestDirectories\TestDataRoot';
values.moreEvents = 'e5, e5 label, e5 description, /a/b/c; e6,e61,e6 des';
values.Attn = 'AttentionShiftSet';
values.BCI2000 = 'BCI2000Set';
values.EEGLAB = 'EEGLABSet';
values.Shooter = 'ShooterSet';

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test

function test_tagdirAttn(values)  %#ok<DEFNU>
% % Unit test for cTagger tagEEGDIR static method 
fprintf('\nUnit tests for tagdir for attention shift data\n');

fprintf('It should work for the attention shift data without GUI\n');
thisDir = [values.TestDirectory filesep values.Attn];
[eTags1, fPaths1] = tagdir(thisDir, 'UseGui', false);
attnEvents1 = eTags1.getEvents();
assertEqual(length(attnEvents1), 17);
assertEqual(length(fPaths1), 6);

fprintf('It should work for the attention shift data with GUI\n');
thisDir = [values.TestDirectory filesep values.Attn];
[eTags2, fPaths2] = tagdir(thisDir);
attnEvents2 = eTags2.getEvents();
assertEqual(length(attnEvents2), 17);
assertEqual(length(fPaths2), 6);

fprintf('It should work for the attention shift data with GUI\n');
thisDir = [values.TestDirectory filesep values.Attn];
[eTags2, fPaths2] = tagdir(thisDir, 'UseGui', true);
attnEvents2 = eTags2.getEvents();
assertEqual(length(attnEvents2), 17);
assertEqual(length(fPaths2), 6);

fprintf('It should work for the attention shift data with GUI and no synchronization\n');
thisDir = [values.TestDirectory filesep values.Attn];
[eTags2, fPaths2] = tagdir(thisDir, 'UseGui', true, 'Synchronize', false);
attnEvents2 = eTags2.getEvents();
assertEqual(length(attnEvents2), 17);
assertEqual(length(fPaths2), 6);

function test_tagdirBCI2000(values)  %#ok<DEFNU>
% Unit test for tagdir for BCI2000 data
fprintf('\nUnit tests for tagdir for BCI2000\n');

fprintf('It should work for the BCI 2000 data without GUI\n');
thisDir = [values.TestDirectory filesep values.BCI2000];
[eTags3, fPaths3] = tagdir(thisDir, 'UseGui', false);
bci2000Events3 = eTags3.getEvents();
assertEqual(length(bci2000Events3), 17);
assertEqual(length(fPaths3), 42);

fprintf('It should work for the BCI 2000 data witht GUI\n');
thisDir = [values.TestDirectory filesep values.BCI2000];
[eTags4, fPaths4] = tagdir(thisDir);
bci2000Events4 = eTags4.getEvents();
assertEqual(length(bci2000Events4), 17);
assertEqual(length(fPaths4), 42);

fprintf('It should work for the BCI 2000 data witht GUI and no synchronization\n');
thisDir = [values.TestDirectory filesep values.BCI2000];
[eTags4, fPaths4] = tagdir(thisDir, 'Synchronize', false);
bci2000Events4 = eTags4.getEvents();
assertEqual(length(bci2000Events4), 17);
assertEqual(length(fPaths4), 42);

function test_tagdirEEGLAB(values)  %#ok<DEFNU>
% Unit test for tagdir for EEGLAB sample data
fprintf('\nUnit tests for tagdir with EEGLAB data\n');

fprintf('It should work for the EEGLAB data without the GUI\n');
thisDir = [values.TestDirectory filesep values.EEGLAB];
[eTags5, fPaths5] = tagdir(thisDir, 'UseGui', false);
eeglabEvents = eTags5.getEvents();
assertEqual(length(eeglabEvents), 2)
assertEqual(length(fPaths5), 3);

fprintf('It should work for the EEGLAB data\n');
thisDir = [values.TestDirectory filesep values.EEGLAB];
[eTags6, fPaths6] = tagdir(thisDir);
eeglabEvents6 = eTags6.getEvents();
fprintf('events: %d, paths: %d\n', length(eeglabEvents6), length(fPaths6));
assertEqual(length(eeglabEvents6), 2)
assertEqual(length(fPaths6), 3);

function test_tagdirShooter(values)  %#ok<DEFNU>
% Unit test for tagdir with shooter data 
fprintf('\nUnit tests for tagdir with shooter data\n');

fprintf('It should work for the shooter data\n');
thisDir = [values.TestDirectory filesep values.Shooter];
[eTags7, fPaths7] = tagdir(thisDir);
shooterEvents7 = eTags7.getEvents();
fprintf('events: %d, paths: %d\n', length(shooterEvents7), length(fPaths7));

