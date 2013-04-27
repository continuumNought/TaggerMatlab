function test_suite = test_tagevents%#ok<STOUT>
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


function testValid(values)  %#ok<DEFNU>
% Unit test for tagevents
fprintf('\nUnit tests for tagevents\n');
[h1, e1] = eventTags.split(values.eJSON1, true);
eTagsBase = eventTags(h1, e1); 
fprintf('It should produce the same values with basic tags and no changes\n');
eTagsNew1 = tagevents(eTagsBase, 'UseGui', false);
events1 = eTagsNew1.getEvents();
assertEqual(length(events1), 3);
hed1 = eTagsNew1.getHedXML();
assertTrue(strcmpi(hed1, eTagsBase.getHedXML()));
fprintf('It should work again for a previously tagged base with the GUI\n');
eTagsNew2 = tagevents(eTagsNew1);
events2 = eTagsNew2.getEvents();
assertEqual(length(events2), 3);
fprintf('It should work when more events are added\n');
[hMore, eMore] = eventTags.split([';' values.moreEvents],  false);
assertTrue(isempty(hMore));
eTagsMore = eventTags(hMore, eMore);
eventsMore = eTagsMore.getEvents();
assertEqual(length(eventsMore), 2);
eTagsNew3 = tagevents(eTagsNew1, 'BaseTags', eTagsMore, 'UseGui', false);
events3 = eTagsNew3.getEvents();
assertEqual(length(events3), 5);
[h4, e4] = eventTags.split(';1, code 1, event 1, /a/b/c, /def', false);
eTagsNew4 = eventTags(h4, e4);
events4 = eTagsNew4.getEvents();
assertEqual(length(events4), 1);
e5 = eventTags.json2Events(['[{"code":"1", "label":"code 1",' ...
       '"description":"event 1", "tags": ["/light/stimulus"]}]']);
eTagsNew5 = eventTags('', e5);
assertTrue(isa(eTagsNew5, 'eventTags'));
eTagsNew6 = tagevents(eTagsNew4, 'BaseTags', eTagsNew5, ...
    'UpdateType', 'OnlyTags', 'UseGui', false);
assertTrue(isa(eTagsNew6, 'eventTags'));

function testValidSyncOff(values)  %#ok<DEFNU>
% Unit test for cTagger tagevents static method 
fprintf('\nUnit tests for tagevents with synchronization off\n');
[h1, e1] = eventTags.split(values.eJSON1, true);
eTagsBase = eventTags(h1, e1); 
fprintf('It should produce the same values with basic tags and no changes\n');
eTagsNew1 = tagevents(eTagsBase, 'UseGui', false, 'Synchronize', false);
events1 = eTagsNew1.getEvents();
assertEqual(length(events1), 3);
hed1 = eTagsNew1.getHedXML();
assertTrue(strcmpi(hed1, eTagsBase.getHedXML()));
fprintf('It should work again for a previously tagged base with the GUI\n');
eTagsNew2 = tagevents(eTagsNew1, 'Synchronize', false);
events2 = eTagsNew2.getEvents();
assertEqual(length(events2), 3);
fprintf('It should work when more events are added\n');
[hMore, eMore] = eventTags.split([';' values.moreEvents],  false);
assertTrue(isempty(hMore));
eTagsMore = eventTags(hMore, eMore);
eventsMore = eTagsMore.getEvents();
assertEqual(length(eventsMore), 2);
eTagsNew3 = tagevents(eTagsNew1, 'BaseTags', eTagsMore, 'UseGui', true, ...
    'Synchronize', false);
events3 = eTagsNew3.getEvents();
assertEqual(length(events3), 5);
[h4, e4] = eventTags.split(';1, code 1, event 1, /a/b/c, /def', false);
eTagsNew4 = eventTags(h4, e4);
events4 = eTagsNew4.getEvents();
assertEqual(length(events4), 1);
e5 = eventTags.json2Events(['[{"code":"1", "label":"code 1",' ...
       '"description":"event 1", "tags": ["/light/stimulus"]}]']);
eTagsNew5 = eventTags('', e5);
assertTrue(isa(eTagsNew5, 'eventTags'));
eTagsNew6 = tagevents(eTagsNew4, 'BaseTags', eTagsNew5, ...
    'UpdateType', 'OnlyTags', 'UseGui', true, 'Synchronize', false);
assertTrue(isa(eTagsNew6, 'eventTags'));