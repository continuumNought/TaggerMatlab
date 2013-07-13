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
values.inMap1 = fieldMap('XML', values.xml);
values.inMap2 = fieldMap('XML', values.xml);
s1 = tagMap.text2Values(values.type);
values.inMap2.addValues('type', s1);
s2 = tagMap.text2Values(values.code);
values.inMap2.addValues('code', s2);
values.inMap2.addValues('group', s2);
values.inMap3 = values.inMap2.clone();

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test

function test_valid(values)  %#ok<DEFNU>
% Unit test for selectmaps with no user interaction
fprintf('\nUnit tests for selectmaps when no user interaction is required\n');
fprintf('It should return an empty map when input map is empty\n');
[fMap1, excluded1] = selectmaps(values.inMap1);
assertTrue(isempty(excluded1));
assertTrue(isempty(fMap1.getFields()));

fprintf('It should return all fields when no Fields or selection\n');
[fMap2, excluded2] = selectmaps(values.inMap2, 'SelectOption', false);
assertEqual(length(values.inMap2.getFields()), length(fMap2.getFields()));
assertTrue(isempty(excluded2));

fprintf('It should correctly exclude fields when Fields are specified\n');
[fMap3, excluded3] = selectmaps(values.inMap2.clone(), ...
       'Fields', {'code', 'group'}, 'SelectOption', false);
fprintf('It should work when there are multiple fields\n');
assertEqual(length(fMap3.getFields()), 2);
assertEqual(length(excluded3), 1);

fprintf('It should correctly exclude fields when not all Fields exist\n');
[fMap4, excluded4] = selectmaps(values.inMap3, ...
       'Fields', {'code', 'group', 'cat'}, 'SelectOption', false);
assertEqual(length(fMap4.getFields()), 2);
assertEqual(length(excluded4), 1);

fprintf('It should return an empty map when input map is empty\n');
[fMap1, excluded1] = selectmaps(values.inMap1.clone(), 'SelectOption', true);
assertTrue(isempty(excluded1));
assertTrue(isempty(fMap1.getFields()));


function test_tag_button(values)  %#ok<DEFNU>
% Unit test for selectmaps interactive use with Tag button
fprintf('\n\nUnit tests for selectmaps interactive use with Tag button\n');
fprintf('....REQUIRES USER INPUT\n');
fprintf('PRESS the TAG BUTTON THREE TIMES\n');
fprintf('It should return all fields when no fields or selection\n');
[fMap2, excluded2] = selectmaps(values.inMap2, 'SelectOption', true);
assertEqual(length(values.inMap2.getFields()), length(fMap2.getFields()));
assertTrue(isempty(excluded2));

function test_field_argument(values)  %#ok<DEFNU>
% Unit test for selectmaps with Tag button and Field argument
fprintf('\n\nUnit tests for selectmaps interactive use with Tag button\n');
fprintf('....REQUIRES USER INPUT\n');
fprintf('\nIt should correctly exclude fields when Fields are specified\n');
fprintf('....REQUIRES USER INPUT\n');
fprintf('PRESS the TAG BUTTON TWICE (should only show code and group)\n');
[fMap3, excluded3] = selectmaps(values.inMap2.clone(), ...
       'Fields', {'code', 'group'}, 'SelectOption', true); 
assertTrue(sum(strcmpi(excluded3{1}, 'type')) == 1);
assertEqual(length(fMap3.getFields()), 2);

fprintf('\nIt should correctly exclude fields when not all Fields exist\n');
fprintf('....REQUIRES USER INPUT\n');
fprintf('PRESS the TAG BUTTON TWICE (should only show code and group)\n');
[fMap4, excluded4] = selectmaps(values.inMap2.clone(), ...
       'Fields', {'code', 'group', 'cat'}, 'SelectOption', true); 
assertTrue(sum(strcmpi(excluded4{1}, 'type')) == 1);
assertEqual(length(fMap4.getFields()), 2);

function test_exclude_button(values)  %#ok<DEFNU>
% Unit test for selectmaps interactive usage with Exclude button
fprintf('\n\nUnit tests for selectmaps interactive use with Exclude button\n');
fprintf('It should exclude the type field from the map\n');
fprintf('....REQUIRES USER INPUT\n');
fprintf('PRESS EXCLUDE BUTTON FOR TYPE\n');
[fMap2, excluded2] = selectmaps(values.inMap2, 'SelectOption', true);
fields2 = fMap2.getFields();
assertEqual(length(fields2), 2);
assertTrue(sum(strcmpi(fields2, 'type'))==0);
assertTrue(sum(strcmpi(excluded2, 'type')) == 1);
assertEqual(length(excluded2), 1);

function test_exclude_all(values)  %#ok<DEFNU>
% Unit test for selectmaps interactive usage with Exclude button
fprintf('\n\nUnit tests for selectmaps interactive excluding all\n');
fprintf('\nIt should work when all fields are excluded\n');
fprintf('....REQUIRES USER INPUT\n');
fprintf('PRESS EXCLUDE BUTTON THREE TIMES\n');
[fMap3, excluded3] = selectmaps(values.inMap2, 'SelectOption', true);
fields3 = fMap3.getFields();
assertTrue(isempty(fields3));
assertEqual(length(excluded3), 3);

function test_successive_use(values)  %#ok<DEFNU>
% Unit test for selectmaps interactive usage when same map is reused
fprintf('\n\nUnit tests for selectmaps when map is reused\n');
fprintf('It should exclude the type field from the map\n');
fprintf('....REQUIRES USER INPUT\n');
fprintf('PRESS EXCLUDE BUTTON FOR TYPE\n');
[fMap2, excluded2] = selectmaps(values.inMap2, 'SelectOption', true);
fields2 = fMap2.getFields();
assertEqual(length(fields2), 2);
assertTrue(sum(strcmpi(fields2, 'type'))==0);
assertTrue(sum(strcmpi(excluded2, 'type')) == 1);
assertEqual(length(excluded2), 1);

fprintf('\n\nIt should only have group and type fields when reselected\n');
fprintf('....REQUIRES USER INPUT\n');
fprintf('PRESS TAG BUTTON TWICE\n');
[fMap3, excluded3] = selectmaps(fMap2, 'SelectOption', true);
fields3 = fMap3.getFields();
assertEqual(length(fields3), 2);
assertTrue(sum(strcmpi(fields3, 'type'))==0);
assertEqual(length(excluded3), 0);
