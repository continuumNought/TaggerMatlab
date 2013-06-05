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
values.data.etc.tags.xml = fileread(latestHed);
values.data.etc.tags.map.type = typeValues;
values.data.etc.tags.map.code = codeValues;
values.data.etc.tags.map.group = codeValues;
values.data.event = struct('type', {'RT', 'Trigger'}, 'code', {'1', '2'});
load EEGEpoch.mat;
values.EEGEpoch = EEGEpoch;

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test

function testValidValues(values)  %#ok<DEFNU>
% Unit test for findtags
fprintf('\nUnit tests for writetags\n');
fprintf('It should tag a data set with no events if rewrite is Summary\n');
x = values.data;
dTags = findtags(x);
assertTrue(isa(dTags, 'fieldMap'));
y1 = writetags(x, dTags, 'RewriteOption', 'Summary');
assertTrue(isfield(y1.etc, 'tags'));
assertTrue(isfield(y1.etc.tags, 'xml'));
assertEqual(length(fieldnames(y1.etc.tags)), 2);
assertTrue(isfield(y1.etc.tags, 'map'));
assertEqual(length(fieldnames(y1.etc.tags.map)), 2);
assertTrue(~isfield(y1.event, 'usertags'));
assertTrue(~isfield(x.event, 'usertags'));


y2 = writetags(x, dTags, 'RewriteOption', 'Both');
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
assertTrue(~isfield(x.event, 'usertags'));

