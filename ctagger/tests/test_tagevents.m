function test_suite = test_tagevents%#ok<STOUT>
initTestSuite;

function values = setup %#ok<DEFNU>
types = {'RT', 'Trigger', 'Missed'};
eStruct = struct('field', 'type', 'xml', 'abc', 'events', 'def');
tags = {'/Time-Locked Event/Stimulus/Visual/Shape/Ellipse/Circle', ...
        '/Time-Locked Event/Stimulus/Visual/Fixation Point', ...
        '/Time-Locked Event/Stimulus/Visual/Uniform Color/Black'};
sE = struct('label', types, 'description', types, 'tags', '');
sE(1).tags = tags;
eStruct.field = 'type';
eStruct.events = sE;
eStruct.xml = fileread('HEDSpecification1.3.xml');
values.eJSON1 = savejson('', eStruct);
values.eStruct1 = eStruct;
values.eventList1 = 'Trigger,code 1,/my/tag1, /my/tag2;Trigger2,t2,';
values.baseList1 = 'Trigger,code 1,/my/tag1/a, /my/tag3';
values.eventList2 = 'Trigger,code 2,/my/tag1, /my/tag2';
values.baseList2 = 'Trigger,code 3,/my/tag3, /my/tag4';
values.eventList3 = 'RT,code 4,/my/tag1, /my/tag2';
values.baseList3 = 'Trigger,code 1,/my/tag4, /my/tag2; RT,code 4,/my/tag1, /my/tag2';

values.emptyEvent = '';
values.eventMissingFields = struct('label', types);
values.eventEmptyTags = struct('label', types, 'description', types, 'tags', '');
values.oneEvent = struct('label', 'abc type', 'description', '', 'tags', '/a/b');
values.noTagsFile = 'EEGEpoch.mat';
values.oneTagsFile = 'etags.mat';
values.otherTagsFile = 'eTagsOther.mat';
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
[f1, h1, e1] = eventTags.split(values.eJSON1, true);
assertTrue(strcmpi(f1, 'type'));
eTagsBase = eventTags(h1, e1); 
fprintf('It should produce the same values with basic tags and no changes\n');
eTagsNew1 = tagevents(eTagsBase, 'UseGui', false);
events1 = eTagsNew1.getEvents();
assertEqual(length(events1), 3);
hed1 = eTagsNew1.getXml();
assertTrue(strcmpi(hed1, eTagsBase.getXml()));
fprintf('It should work again for a previously tagged base with the GUI\n');
eTagsNew2 = tagevents(eTagsNew1);
events2 = eTagsNew2.getEvents();
assertEqual(length(events2), 3);
fprintf('It should work when more events are added\n');
[fMore, hMore, eMore] = eventTags.split([';;' values.moreEvents],  false);
assertTrue(isempty(hMore));
assertTrue(isempty(fMore));
eTagsMore = eventTags(hMore, eMore);
eventsMore = eTagsMore.getEvents();
assertEqual(length(eventsMore), 2);
eTagsNew3 = tagevents(eTagsNew1, 'BaseTags', eTagsMore, 'UseGui', false);
events3 = eTagsNew3.getEvents();
assertEqual(length(events3), 5);
[f4, h4, e4] = eventTags.split(';; code 1, event 1, /a/b/c, /def', false);
assertTrue(isempty(f4));
eTagsNew4 = eventTags(h4, e4);
events4 = eTagsNew4.getEvents();
assertEqual(length(events4), 1);
e5 = eventTags.json2Events(['[{"label":"code 1",' ...
       '"description":"event 1", "tags": ["/light/stimulus"]}]']);
eTagsNew5 = eventTags('', e5);
assertTrue(isa(eTagsNew5, 'eventTags'));
eTagsNew6 = tagevents(eTagsNew4, 'BaseTags', eTagsNew5, ...
    'UpdateType', 'OnlyTags', 'UseGui', false);
assertTrue(isa(eTagsNew6, 'eventTags'));

function testValidSyncOn(values)  %#ok<DEFNU>
% Unit test for cTagger tagevents static method 
fprintf('\nUnit tests for tagevents with synchronization on\n');
[f1, h1, e1] = eventTags.split(values.eJSON1, true);
assertTrue(strcmpi('type', f1));
eTagsBase = eventTags(h1, e1); 
fprintf('It should produce the same values with basic tags and no changes\n');
eTagsNew1 = tagevents(eTagsBase, 'UseGui', false, 'Synchronize', true);
events1 = eTagsNew1.getEvents();
assertEqual(length(events1), 3);
hed1 = eTagsNew1.getXml();
assertTrue(strcmpi(hed1, eTagsBase.getXml()));
fprintf('It should work again for a previously tagged base with the GUI\n');
eTagsNew2 = tagevents(eTagsNew1, 'Synchronize', true);
events2 = eTagsNew2.getEvents();
assertEqual(length(events2), 3);
fprintf('It should work when more events are added\n');
[fMore, hMore, eMore] = eventTags.split([';;' values.moreEvents],  false);
assertTrue(isempty(fMore));
assertTrue(isempty(hMore));
eTagsMore = eventTags(hMore, eMore);
eventsMore = eTagsMore.getEvents();
assertEqual(length(eventsMore), 2);
eTagsNew3 = tagevents(eTagsNew1, 'BaseTags', eTagsMore, 'UseGui', true, ...
    'Synchronize', true);
events3 = eTagsNew3.getEvents();
assertEqual(length(events3), 5);
[f4, h4, e4] = eventTags.split(';;code 1, event 1, /a/b/c, /def', false);
assertTrue(isempty(f4));
eTagsNew4 = eventTags(h4, e4);
events4 = eTagsNew4.getEvents();
assertEqual(length(events4), 1);
e5 = eventTags.json2Events(['[{"label":"code 1",' ...
       '"description":"event 1", "tags": ["/light/stimulus"]}]']);
eTagsNew5 = eventTags('', e5);
assertTrue(isa(eTagsNew5, 'eventTags'));
eTagsNew6 = tagevents(eTagsNew4, 'BaseTags', eTagsNew5, ...
    'UpdateType', 'OnlyTags', 'UseGui', true, 'Synchronize', true);
assertTrue(isa(eTagsNew6, 'eventTags'));

function testValidSyncOff(values)  %#ok<DEFNU>
% Unit test for cTagger tagevents static method 
fprintf('\nUnit tests for tagevents with synchronization off\n');
[f1, h1, e1] = eventTags.split(values.eJSON1, true);
assertTrue(strcmpi(f1, 'type'));
eTagsBase = eventTags(h1, e1); 
fprintf('It should produce the same values with basic tags and no changes\n');
eTagsNew1 = tagevents(eTagsBase, 'UseGui', false, 'Synchronize', false);
events1 = eTagsNew1.getEvents();
assertEqual(length(events1), 3);
hed1 = eTagsNew1.getXml();
assertTrue(strcmpi(hed1, eTagsBase.getXml()));
fprintf('It should work again for a previously tagged base with the GUI\n');
eTagsNew2 = tagevents(eTagsNew1, 'Synchronize', false);
events2 = eTagsNew2.getEvents();
assertTrue(~isempty(events2));
