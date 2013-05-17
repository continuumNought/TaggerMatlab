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
dTags = findtags(values.EEGEpoch);
events = dTags.getEventTags();
assertEqual(length(events), 2);
assertTrue(~isempty(dTags.getXml()));
fprintf('It should work if EEG doesn''t have .etc field\n');
EEG1 = values.EEGEpoch;
EEG1 = rmfield(EEG1, 'etc');
dTags1 = findtags(EEG1);
events1 = dTags1.getEventTags();
assertEqual(length(events1), 2);
assertTrue(~isempty(dTags1.getXml()));
fprintf('It should work if EEG has an empty .etc field\n');
EEG2 = values.EEGEpoch;
EEG2.etc = '';
dTags2 = findtags(EEG2);
events2 = dTags2.getEventTags();
assertEqual(length(events2), 2);
assertTrue(~isempty(dTags2.getXml()));
fprintf('It should work if EEG has a non-structure .etc field\n');
EEG3 = values.EEGEpoch;
EEG3.etc = 'This is a test';
dTags3 = findtags(EEG3);
events3 = dTags3.getEventTags();
assertEqual(length(events3), 2);
assertTrue(~isempty(dTags3.getXml()));
fprintf('It should work if the EEG has already been tagged\n');
json1 = dTags1.getJson();
EEG3.etc.eventHedTags = json1;
dTags4 = findtags(EEG3);
events4 = dTags4.getEventTags();
assertEqual(length(events4), 2);
assertTrue(~isempty(dTags4.getXml()));

function testMultipleFields(values)  %#ok<DEFNU>
% Unit test for findtags
fprintf('\nUnit tests for findtags with multiple field combinations\n');
fprintf('It should tag when the epoch field is not excluded\n');
assertTrue(~isfield(values.EEGEpoch.etc, 'tags'));
dTags = findtags(values.EEGEpoch, 'ExcludeFields', {'latency', 'urevent'});
events = dTags.getEventTags();
assertEqual(length(events), 3);
e1 = events{1}.getStruct();
assertTrue(strcmpi(e1.field, 'epoch'));
assertEqual(length(e1.events), 80);
e2 = events{2}.getStruct();
assertTrue(strcmpi(e2.field, 'position'));
assertEqual(length(e2.events), 2);
e3 = events{3}.getStruct();
assertTrue(strcmpi(e3.field, 'type'));
assertEqual(length(e3.events), 2);

