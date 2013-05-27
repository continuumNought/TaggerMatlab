function test_suite = test_tageeg%#ok<STOUT>
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
fprintf('It should tag a data set that has a map but no events\n');
fName = 'temp1.mat';
x = values.data;
[y, fMap, excluded] = tageeg(x, 'RewriteOption', 'both', ...
        'UseGui', false', 'SaveMapName', fName);
assertEqual(length(excluded), 5);
assertTrue(isfield(y.etc, 'tags'));
assertTrue(isfield(y.etc.tags, 'xml'));
assertEqual(length(fieldnames(y.etc.tags)), 2);
assertTrue(isfield(y.etc.tags, 'map'));
assertEqual(length(fieldnames(y.etc.tags.map)), 2);
fNew = fieldMap.loadFieldMap(fName);
assertTrue(isa(fNew, 'fieldMap'));
delete(fName);
