function test_suite = test_editmaps_db%#ok<STOUT>
initTestSuite;

function values = setup %#ok<DEFNU>
setup_tests;
typeValues = ['RT,User response,' ...
    '/Time-Locked Event/Stimulus/Visual/Shape/Ellipse/Circle,' ...
    '/Time-Locked Event/Stimulus/Visual/Uniform Color/Black;' ...
    'Trigger,User stimulus,,;Missed,User failed to respond,'];
values.type = typeValues;
values.map1 = fieldMap();
s1 = tagMap.text2Values(values.type);
values.map1.addValues('type', s1);

function testXml(values)  %#ok<DEFNU>
fprintf('\nThe fieldMap xml should not be changed\n');
fprintf('....REQUIRES USER INPUT\n');
fprintf('PRESS SUBMIT AFTER NO CHANGES\n');
createdbc(which(values.dbfile));
fMap1 = values.map1;
fMap1 = editmaps_db(fMap1, 'DbCreds', which(values.dbfile));
originalXml = fMap1.getXml();
fprintf('PRESS SUBMIT AGAIN AFTER NO CHANGES\n');
fMap2 = editmaps_db(fMap1, 'DbCreds', which(values.dbfile));
newXml = fMap2.getXml();
assertEqual(length(originalXml), length(newXml));
fprintf('ADD A NEW TAG TO THE TAG HIERARCHY THEN PRESS SUBMIT\n');
fMap3 = editmaps_db(fMap1, 'DbCreds', which(values.dbfile));
newXml = fMap3.getXml();
assertFalse(isequal(length(originalXml), length(newXml)));
deletedbc(which(values.dbfile));
