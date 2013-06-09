function test_suite = test_editmaps%#ok<STOUT>
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
values.map1 = fieldMap('XML', values.xml);
s1 = tagMap.text2Values(values.type);
values.map1.addValues('type', s1);

values.map2 = fieldMap('XML', values.xml);
values.map2.addValues('type', s1);
s2 = tagMap.text2Values(values.code);
values.map2.addValues('code', s2);
values.map2.addValues('group', s2);

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test


function testValid(values)  %#ok<DEFNU>
% Unit test for editmaps
    fprintf('\nUnit tests for editmaps increase indent\n');
    fprintf('It should work present multiple GUIs\n');
    fprintf('....REQUIRES USER INPUT\n');
    fprintf('PRESS ANY GUI BUTTON\n');
    fMap = values.map1;
    fMap1 = editmaps(fMap.clone());
    assertEqual(fMap1, values.map1);
  
 