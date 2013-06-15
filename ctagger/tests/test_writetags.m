function test_suite = test_writetags%#ok<STOUT>
initTestSuite;

function values = setup %#ok<DEFNU>
typeValues = ['RT,User response,' ...
        '/Time-Locked Event/Stimulus/Visual/Shape/Ellipse/Circle,' ...
        '/Time-Locked Event/Stimulus/Visual/Uniform Color/Black;' ...
        'Trigger,User stimulus,,;Missed,User failed to respond,'];
codeValues = ['1,User response,' ...
        '/Time-Locked Event/Stimulus/Visual/Shape/Ellipse/Square,' ...
        '/Time-Locked Event/Stimulus/Visual/Uniform Color/Blue;' ...
        '2,User stimulus,,;3,User failed to respond,'];
% Read in the HED schema
latestHed = 'HEDSpecification1.3.xml';
values.data1.etc.tags.xml = fileread(latestHed);
% map(3) = struct('field', '', 'values', '');
% map(1).field = 'type';
% map(1).values = typeValues;
% map(2).field = 'code';
% map(2).values = codeValues;
% map(3).field = 'group';
% map(3).values = codeValues;
% values.data1.etc.tags.map = map;
% values.data2 = values.data1;
% values.data2.event = struct('type', {'RT', 'Trigger'}, 'code', {'1', '2'});
values.xml = fileread(latestHed);
values.type = typeValues;
values.code = codeValues;
values.group = codeValues;
values.map1 = fieldMap('XML', values.xml);
s1 = tagMap.text2Values(values.type);
values.map1.addValues('type', s1);
s2 = tagMap.text2Values(values.code);
values.map1.addValues('code', s2);
values.map1.addValues('group', s2);
values.data.etc.tags = values.map1.getStruct();
values.data.event = struct('type', {'RT', 'Trigger'}, 'code', {'1', '2'});
values.data1.etc.tags = values.map1.getStruct();
values.data2 = values.data;
load EEGEpoch.mat;
values.EEGEpoch = EEGEpoch;

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test

function testValidValuesSummary(values)  %#ok<DEFNU>
% Unit test for findtags
fprintf('\nUnit tests for writetags\n');
fprintf('It should tag a data set with no events if rewrite is Summary\n');
x1 = values.data1;
dTags1 = findtags(x1);
assertTrue(isa(dTags1, 'fieldMap'));
y1 = writetags(x1, dTags1, 'RewriteOption', 'Summary');
assertTrue(isfield(y1.etc, 'tags'));
assertTrue(isfield(y1.etc.tags, 'xml'));
assertEqual(length(fieldnames(y1.etc.tags)), 2);
assertTrue(isfield(y1.etc.tags, 'map'));
assertTrue(~isempty(y1.etc.tags.map));
assertTrue(~isfield(y1, 'event'));
assertTrue(~isfield(x1, 'event'));

fprintf('It should not tag events even if data has an .event field if Summary\n');
x2 = values.data2;
dTags2 = findtags(x2);
y2 = writetags(x2, dTags2, 'RewriteOption', 'Summary');
assertTrue(isfield(y2.etc, 'tags'));
assertTrue(isfield(y2.etc.tags, 'xml'));
assertEqual(length(fieldnames(y2.etc.tags)), 2);
assertTrue(isfield(y2.etc.tags, 'map'));
assertEqual(length(fieldnames(y2.etc.tags.map)), 2);
assertTrue(isfield(y2, 'event'));
assertTrue(isfield(x2, 'event'))
assertTrue(~isfield(y2.event, 'usertags'));
assertTrue(~isfield(x2.event, 'usertags'));

function testValidValuesBoth(values)  %#ok<DEFNU>
fprintf('It should  tag events  if data has an .event field and option is Both\n');
x2 = values.data2;
dTags2 = findtags(x2);
y2 = writetags(x2, dTags2, 'RewriteOption', 'Both');
assertTrue(isfield(y2.etc, 'tags'));
assertTrue(isfield(y2.etc.tags, 'xml'));
assertEqual(length(fieldnames(y2.etc.tags)), 2);
assertTrue(isfield(y2.etc.tags, 'map'));
assertEqual(length(fieldnames(y2.etc.tags.map)), 2);
assertTrue(isfield(y2.event, 'usertags'));
assertTrue(~isempty(y2.event(1).usertags));
s = regexpi(y2.event(1).usertags, ',', 'split');
assertEqual(length(s), 4);
assertTrue(isempty(y2.event(2).usertags));
assertTrue(~isfield(x2.event, 'usertags'));


