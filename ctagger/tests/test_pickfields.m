function test_suite = test_pickfields%#ok<STOUT>
initTestSuite;

function values = setup %#ok<DEFNU>
typeValues = ['RT,User response,' ...
        '/Time-Locked Event/Stimulus/Visual/Shape/Ellipse/Circle,' ...
        '/Time-Locked Event/Stimulus/Visual/Uniform Color/Black;' ...
        'Trigger,User stimulus,,;Missed,User failed to respond,'];
codeValues = ['1,User response,' ...
        '/Time-Locked Event/Stimulus/Visual/Shape/Ellipse/Circle,' ...
        '/Time-Locked Event/Stimulus/Visual/Uniform Color/Black;' ...
        '2,User stimulus,,;3,User failed to respond,'];
% Read in the HED schema
latestHed = 'HEDSpecification1.3.xml';
values.xml = fileread(latestHed);
values.type = typeValues;
values.code = codeValues;
values.group = codeValues;
load EEGEpoch.mat;
values.EEGEpoch = EEGEpoch;

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test


function testValid(values)  %#ok<DEFNU>
% Unit test for tagevents
fprintf('\nUnit tests for pickfields\n');
fprintf('These tests require user intervention\n');
fprintf('It should return an empty map when input map is empty\n');
inMap = fieldMap(values.xml);
[skip1, exclude1] = pickfields(inMap);
assertTrue(isempty(skip1));
assertTrue(isempty(exclude1));

s1 = tagMap.text2Events(values.type);
inMap.addEvents('type', s1, 'Merge');
fprintf('It should work when there is only a type field\n');
[skip2, exclude2] = pickfields(inMap);
fprintf('...skip has %d values and exclude has %d values \n', ...
    length(skip2), length(exclude2));

fprintf('It should work when there are multiple fields\n');
s2 = tagMap.text2Events(values.code);
inMap.addEvents('code', s2, 'Merge');
inMap.addEvents('group', s2, 'Merge');
[skip3, exclude3] = pickfields(inMap);
fprintf('...skip has %d values and exclude has %d values \n', ...
    length(skip3), length(exclude3));
