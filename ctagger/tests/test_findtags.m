function test_suite = test_findtags%#ok<STOUT>
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
values.TestDirectories = 'H:\TagTestDirectories';
values.moreEvents = 'e5, e5 label, e5 description, /a/b/c; e6,e61,e6 des';
values.Attn = 'AttentionShiftSet';
values.BCI2000 = 'BCI2000Set';
values.EEGLAB = 'EEGLABSet';
values.Shooter = 'ShooterSet';

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test

function testValidValues(values)  %#ok<DEFNU>
% Unit test for findtags
fprintf('\nUnit tests for findtags\n');
fprintf('It should tag an EEG structure that hasn''t been tagged\n');
assertTrue(~isfield(values.EEGEpoch.etc, 'tags'));
eTags = findtags(values.EEGEpoch);
events = eTags.getEvents();
assertEqual(length(events), 2);
assertTrue(~isempty(eTags.getXml()));
fprintf('It should work if EEG doesn''t have .etc field\n');
EEG1 = values.EEGEpoch;
EEG1 = rmfield(EEG1, 'etc');
eTags1 = findtags(EEG1);
events1 = eTags1.getEvents();
assertEqual(length(events1), 2);
assertTrue(~isempty(eTags1.getXml()));
fprintf('It should work if EEG has an empty .etc field\n');
EEG2 = values.EEGEpoch;
EEG2.etc = '';
eTags2 = findtags(EEG2);
events2 = eTags2.getEvents();
assertEqual(length(events2), 2);
assertTrue(~isempty(eTags2.getXml()));
fprintf('It should work if EEG has a non-structure .etc field\n');
EEG3 = values.EEGEpoch;
EEG3.etc = 'This is a test';
eTags3 = findtags(EEG3);
events3 = eTags3.getEvents();
assertEqual(length(events3), 2);
assertTrue(~isempty(eTags3.getXml()));
fprintf('It should work if the EEG has already been tagged\n');
json1 = eTags1.getJson();
EEG3.etc.eventHedTags = json1;
eTags4 = findtags(EEG3);
events4 = eTags4.getEvents();
assertEqual(length(events4), 2);
assertTrue(~isempty(eTags4.getXml()));
