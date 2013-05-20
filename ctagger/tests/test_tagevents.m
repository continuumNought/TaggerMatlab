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
[f1, h1, e1] = tagMap.split(values.eJSON1, true);
assertTrue(strcmpi(f1, 'type'));
dTagsBase = typeMap(h1);
dTagsBase.addEvents(f1, e1, 'Merge');
fprintf('It should produce the same values with basic tags and no changes\n');
dTagsNew1 = tagevents(dTagsBase, 'UseGui', false);
events1 = dTagsNew1.getEventTags();
assertEqual(length(events1), 1);
assertEqual(length(events1{1}.getEvents()), 3);
hed1 = dTagsNew1.getXml();
assertTrue(strcmpi(hed1, dTagsBase.getXml()));
fprintf('It should work again for a previously tagged base with the GUI\n');
dTagsNew2 = tagevents(dTagsNew1);
events2 = dTagsNew2.getEventTags();
assertEqual(length(events2), 1);
assertEqual(length(events1{1}.getEvents()), 3);
fprintf('It should work when more events are added\n');
[fMore, hMore, eMore] = tagMap.split(['type;;' values.moreEvents],  false);
assertTrue(isempty(hMore));
dTagsMore = typeMap(hMore);
dTagsMore.addEvents(fMore, eMore, 'Merge');
eventsM = dTagsMore.getEventTags();
eventsMore = eventsM{1}.getEvents();
assertEqual(length(eventsMore), 2);
dTagsNew3 = tagevents(dTagsNew1, 'BaseTags', dTagsMore, 'UseGui', false);
events3a = dTagsNew3.getEventTags();
events3 = events3a{1}.getEvents();
assertEqual(length(events3), 5);
[f4, h4, e4] = tagMap.split('type;; code 1, event 1, /a/b/c, /def', false);
dTagsNew4 = typeMap(h4);
dTagsNew4.addEvents(f4, e4, 'Merge');
events4a = dTagsNew4.getEventTags();
events4 = events4a{1}.getEvents();
assertEqual(length(events4), 1);
e5 = tagMap.json2Events(['[{"label":"code 1",' ...
       '"description":"event 1", "tags": ["/light/stimulus"]}]']);
eTagsNew5 = tagMap('', e5, 'Field', 'type');
dTags5 = typeMap('');
dTags5.addEventTags(eTagsNew5, 'Merge');
assertTrue(isa(eTagsNew5, 'tagMap'));
dTagsNew6 = tagevents(dTagsNew4, 'BaseTags', dTags5, ...
    'UpdateType', 'OnlyTags', 'UseGui', false);
assertTrue(isa(dTagsNew6, 'typeMap'));

function testValidSyncOn(values)  %#ok<DEFNU>
% Unit test for cTagger tagevents static method 
fprintf('\nUnit tests for tagevents with synchronization on\n');
[f1, h1, e1] = tagMap.split(values.eJSON1, true);
assertTrue(strcmpi('type', f1));
dTagsBase = typeMap(h1);
dTagsBase.addEvents(f1, e1, 'Merge');
fprintf('It should produce the same values with basic tags and no changes\n');
dTagsNew1 = tagevents(dTagsBase, 'UseGui', false, 'Synchronize', true);
events1 = dTagsNew1.getEventTags();
events1a = events1{1}.getEvents();
assertEqual(length(events1a), 3);
hed1 = dTagsNew1.getXml();
assertTrue(strcmpi(hed1, dTagsBase.getXml()));
fprintf('It should work again for a previously tagged base with the GUI\n');
dTagsNew2 = tagevents(dTagsNew1, 'Synchronize', true);
events2 = dTagsNew2.getEventTags();
events2a = events2{1}.getEvents();
assertEqual(length(events2a), 3);
fprintf('It should work when more events are added\n');
[fMore, hMore, eMore] = tagMap.split(['type;;' values.moreEvents],  false);
assertTrue(isempty(hMore));
dTagsMore = typeMap(hMore);
dTagsMore.addEvents(fMore, eMore, 'Merge');
eventsMore = dTagsMore.getEventTags();
assertEqual(length(eventsMore{1}.getEvents()), 2);
dTagsNew3 = tagevents(dTagsNew1, 'BaseTags', dTagsMore, 'UseGui', true, ...
    'Synchronize', true);
events3 = dTagsNew3.getEventTags();
assertEqual(length(events3{1}.getEvents()), 5);
[f4, h4, e4] = tagMap.split('type;;code 1, event 1, /a/b/c, /def', false);
dTagsNew4 = typeMap(h4);
dTagsNew4.addEvents(f4, e4, 'Merge');
events4 = dTagsNew4.getEventTags();
assertEqual(length(events4{1}.getEvents()), 1);

function testValidSyncOff(values)  %#ok<DEFNU>
% Unit test for cTagger tagevents static method 
fprintf('\nUnit tests for tagevents with synchronization off\n');
[f1, h1, e1] = tagMap.split(values.eJSON1, true);
assertTrue(strcmpi(f1, 'type'));
dTagsBase = typeMap(h1);
dTagsBase.addEvents(f1, e1, 'Merge');
fprintf('It should produce the same values with basic tags and no changes\n');
dTagsNew1 = tagevents(dTagsBase, 'UseGui', false, 'Synchronize', false);
events1 = dTagsNew1.getEventTags();
assertEqual(length(events1{1}.getEvents()), 3);
hed1 = dTagsNew1.getXml();
assertTrue(strcmpi(hed1, dTagsBase.getXml()));
fprintf('It should work again for a previously tagged base with the GUI\n');
dTagsNew2 = tagevents(dTagsNew1, 'Synchronize', false);
events2 = dTagsNew2.getEventTags();
assertTrue(~isempty(events2));
