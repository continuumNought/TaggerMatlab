function test_suite = test_selectmaps%#ok<STOUT>
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
values.inMap1 = fieldMap(values.xml);
values.inMap2 = fieldMap(values.xml);
s1 = tagMap.text2Values(values.type);
values.inMap2.addValues('type', s1, 'Merge');
s2 = tagMap.text2Values(values.code);
values.inMap2.addValues('code', s2, 'Merge');
values.inMap2.addValues('group', s2, 'Merge');
values.inMap3 = values.inMap2.clone();

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test

function testValid(values)  %#ok<DEFNU>
% Unit test for tagevents
fprintf('\nUnit tests for selectmaps\n');
fprintf('It should return an empty map when input map is empty\n');
[fMap1, excluded1] = selectmaps(values.inMap1);
assertTrue(isempty(excluded1));
assertTrue(isempty(fMap1.getFields()));

fprintf('It should return all fields when no Fields or selection\n');
[fMap2, excluded2] = selectmaps(values.inMap2, 'SelectOption', false);
assertEqual(length(values.inMap2.getFields()), length(fMap2.getFields()));
assertTrue(isempty(excluded2));

fprintf('It should correctly exclude fields when Fields are specified\n');
[fMap3, excluded3] = selectmaps(values.inMap2, ...
       'Fields', {'code', 'group'}, 'SelectOption', false);
fprintf('It should work when there are multiple fields\n');
assertEqual(length(fMap3.getFields()), 2);
assertEqual(length(excluded3), 1);


fprintf('It should correctly exclude fields when not all Fields exist\n');
[fMap4, excluded4] = selectmaps(values.inMap3, ...
       'Fields', {'code', 'group', 'cat'}, 'SelectOption', false);
assertEqual(length(fMap4.getFields()), 2);
assertEqual(length(excluded4), 1);


function testValidInteractive(values)  %#ok<DEFNU>
% Unit test for tagevents
% fprintf('\nUnit tests for selectmaps\n');
% fprintf('These tests require user intervention\n');
fprintf('\nUnit tests for selectmaps\n');
fprintf('....REQUIRES USER INPUT\n');
fprintf('PRESS the TAG BUTTON ALWAYS\n');
fprintf('It should return an empty map when input map is empty\n');
[fMap1, excluded1] = selectmaps(values.inMap1, 'SelectOption', true);
assertTrue(isempty(excluded1));
assertTrue(isempty(fMap1.getFields()));

fprintf('It should return all fields when no Fields or selection\n');
[fMap2, excluded2] = selectmaps(values.inMap2, 'SelectOption', true);
assertEqual(length(values.inMap2.getFields()), length(fMap2.getFields()));
assertTrue(isempty(excluded2));

fprintf('It should correctly exclude fields when Fields are specified\n');
[fMap3, excluded3] = selectmaps(values.inMap2, ...
       'Fields', {'code', 'group'}, 'SelectOption', true); %#ok<ASGLU,NASGU>


fprintf('It should correctly exclude fields when not all Fields exist\n');
[fMap4, excluded4] = selectmaps(values.inMap3, ...
       'Fields', {'code', 'group', 'cat'}, 'SelectOption', true); %#ok<NASGU,ASGLU>
