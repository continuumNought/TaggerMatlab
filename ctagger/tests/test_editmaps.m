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
values.map1 = fieldMap(values.xml);
s1 = tagMap.text2Events(values.type);
values.map1.addEvents('type', s1, 'Merge');

values.map2 = fieldMap(values.xml);
values.map2.addEvents('type', s1, 'Merge');
s2 = tagMap.text2Events(values.code);
values.map2.addEvents('code', s2, 'Merge');
values.map2.addEvents('group', s2, 'Merge');

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test


function testValid(values)  %#ok<DEFNU>
% Unit test for editmaps
    fprintf('\nUnit tests for editmaps increase indent\n');
    fprintf('It should work present multiple GUIs\n');
    fMap = values.map1;
    fMap1 = editmaps(fMap.clone());
    assertEqual(fMap1, values.map1);
  
 
  function testNotSynchronized(values)  %#ok<DEFNU>
% Unit test for editmaps
  fprintf('\nUnit tests for editmaps not synchronized\n');
  fprintf('It should work when and present multiple GUIs\n');
  fMap = values.map1;
  fMap1 = editmaps(fMap.clone(), 'Synchronize', false);
  assertEqual(fMap1, values.map1);
  