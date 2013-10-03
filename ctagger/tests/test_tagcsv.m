function test_suite = test_tagcsv%#ok<STOUT>
initTestSuite;

function values = setup %#ok<STOUT,DEFNU>
setup_tests;

function teardown(values) %#ok<INUSD,DEFNU>

function test_tagcsvEmpty(values)   %#ok<DEFNU>
% Unit test for tagcsv function with empty directory
fprintf('\nBe sure to edit setup_tests.m before running this test\n');
fprintf('\nUnit tests for tagcsv for empty file\n');

fprintf('It should work when there is an empty file ---WARNING\n');
eTags1 = tagcsv(values.emptyfile, 'UseGui', false);
assertTrue(isa(eTags1, 'fieldMap'));
keys = eTags1.getFields();
assertTrue(isempty(keys));
fprintf('It should work when there is an invalid ---WARNING\n');
eTags2 = tagcsv('--34', 'UseGui', false);
assertTrue(isa(eTags2, 'fieldMap'));
assertTrue(isempty(eTags2.getFields()));

function test_tagcsvBasic(values)  %#ok<DEFNU>
%Unit test for tagcsv for basic stuff
fprintf('\nUnit tests for tagcsv only filename\n');
fprintf('....PRESS SUBMIT WITHOUT TAGGING FOR EACH GUI\n');
fprintf('It should work with only the filename as an argument\n');
fMap1 = tagcsv(values.efile2);
obj1 = csvMap(values.efile2);
events1 = obj1.getEvents();
type1 = obj1.getType();
types = fMap1.getFields();
assertEqual(length(types), 1);
assertTrue(strcmpi(type1, types{1}));
tMap = fMap1.getMap(types{1});
tEvents = tMap.getValues();
assertEqual(length(tEvents), length(events1));

function test_tagcsvBaseMap(values) %#ok<DEFNU>
fprintf('\nUnit tests for tagcsv with BaseMap argument\n');
fprintf('There should be a tags column');
fprintf(['The csv rewrite file should have two tags written to every' ...
    ' (1|1|1) event']);
csvFile = 'testcsv.csv';
tagcsv(values.efile3, 'BaseMap', 'fMapThree', 'RewriteFile', ...
    csvFile, 'UseGui', false);
obj1 = csvMap(csvFile);
header1 = obj1.getHeader();
values1 = obj1.getValues();
tagsRow1 = values1{2};
tags1 = strsplit(tagsRow1{4}, '|');
tagsRow2 = values1{3};
tags2 = strsplit(tagsRow2{4}, '|');
assertEqual(length(tags1), 2);
assertEqual(length(tags2), 2);
assertEqual(header1{4}, 'Tags');
delete(csvFile);

function test_tagcsvSaveMapFile(values) %#ok<DEFNU>
fprintf('\nUnit tests for tagcsv with SaveMapFile argument\n');
fprintf('....PRESS SUBMIT WITHOUT TAGGING FOR GUI\n');
mapFile = 'fMapTest';
tagcsv(values.efile3, 'SaveMapFile', mapFile);
load(mapFile);
assertTrue(isa(fMap, 'fieldMap'));
delete([mapFile '.mat']);


function test_tagcsvRewrite(values)  %#ok<DEFNU>
%Unit test for tagcsv with rewrite file
fprintf('\nUnit tests for tagcsv with rewrite file\n');

fprintf(['It should work with RewriteFile as an argument without a' ...
    ' tags and description column specified\n']);
fprintf('....PRESS SUBMIT WITHOUT TAGGING FOR GUI\n');
fprintf(['The csv rewrite file should not have a tags or description' ...
    ' column']);
obj1 = csvMap(values.efile2);
csvFile = 'testcsv.csv';
tagcsv(values.efile2, 'RewriteFile', csvFile);
obj2 = csvMap(csvFile);
header1 = obj1.getHeader();
header2 = obj2.getHeader();
assertTrue(exist(csvFile,'file') > 0)
assertEqual(length(header1) + 1, length(header2));
assertEqual(header2{4}, 'Tags');
delete(csvFile);

fprintf(['It should work with RewriteFile as an argument with a tags ' ...
    ' column specified\n']);
fprintf(['....PRESS SUBMIT AFTER ADDING 2 TAGS TO THE FIRST EVENT' ...
    ' (1|1|1)\n']);
fprintf('The csv rewrite file should have a tags column');
obj1 = csvMap(values.efile2);
csvFile = 'testcsv.csv';
tagcsv(values.efile2, 'RewriteFile', csvFile, 'TagsColumn', 4);
obj2 = csvMap(csvFile);
header1 = obj1.getHeader();
header2 = obj2.getHeader();
values2 = obj2.getValues();
tagsRow = values2{2};
tags = strsplit(tagsRow{4}, '|');
assertTrue(exist(csvFile,'file') > 0)
assertEqual(length(header1) + 1, length(header2));
assertEqual(header2{4}, 'Tags');
assertEqual(length(tags), 2);
delete(csvFile);

fprintf(['It should work with RewriteFile as an argument with a' ...
    ' description column specified\n']);
fprintf(['....PRESS SUBMIT AFTER ADDING A DESCRIPTION TO THE FIRST EVENT' ...
    ' (1|1|1)\n']);
fprintf('The csv rewrite file should have a tags column');
obj1 = csvMap(values.efile2);
csvFile = 'testcsv.csv';
tagcsv(values.efile2, 'RewriteFile', csvFile, 'DescriptionColumn', 4);
obj2 = csvMap(csvFile);
header1 = obj1.getHeader();
header2 = obj2.getHeader();
values2 = obj2.getValues();
descriptionRow = values2{2};
description = descriptionRow{4};
assertTrue(exist(csvFile,'file') > 0)
assertEqual(length(header1) + 1, length(header2));
assertEqual(header2{4}, 'Description');
assertTrue(~isempty(description));
delete(csvFile);

fprintf(['It should work with RewriteFile as an argument with a' ...
    ' tags and description column specified\n']);
fprintf(['....PRESS SUBMIT AFTER ADDING 2 TAGS AND A DESCRIPTION' ...
    ' TO THE FIRST EVENT (1|1|1)\n']);
fprintf('The csv rewrite file should have a tags column');
obj1 = csvMap(values.efile2);
csvFile = 'testcsv.csv';
tagcsv(values.efile2, 'RewriteFile', csvFile, 'TagsColumn', 4, ...
    'DescriptionColumn', 5);
obj2 = csvMap(csvFile);
header1 = obj1.getHeader();
header2 = obj2.getHeader();
values2 = obj2.getValues();
tagDescriptionRow = values2{2};
tags = strsplit(tagDescriptionRow{4}, '|');
description = tagDescriptionRow{5};
assertTrue(exist(csvFile,'file') > 0)
assertEqual(length(header1) + 2, length(header2));
assertEqual(header2{4}, 'Tags');
assertEqual(header2{5}, 'Description');
assertEqual(length(tags), 2);
assertTrue(~isempty(description));
delete(csvFile);

fprintf(['It should work with RewriteFile as an argument with a' ...
    ' tags and description column specified\n']);
fprintf(['....PRESS SUBMIT AFTER ADDING 2 TAGS AND UPDATING THE' ...
    ' DESCRIPTION TO THE FIRST EVENT (1|1|1)\n']);
fprintf(['There should be 2 more tags and an updated description added' ...
    ' to the first event (1|1|1)']);
obj1 = csvMap(values.efile1);
csvFile = 'testcsv.csv';
tagcsv(values.efile1, 'EventColumns', [1, 3, 5], 'DescriptionColumn', ...
    8,'TagsColumn', 7, 'RewriteFile', csvFile);
obj2 = csvMap(csvFile);
header1 = obj1.getHeader();
header2 = obj2.getHeader();
values1 = obj1.getValues();
values2 = obj2.getValues();
tagDescriptionRow1 = values1{2};
tagDescriptionRow2 = values2{2};
tags = strsplit(tagDescriptionRow2{7}, '|');
description1 = tagDescriptionRow1{8};
description2 = tagDescriptionRow2{8};
assertEqual(length(header1), length(header2));
assertEqual(length(tags), 3);
assertTrue(~isequal(description1, description2));
delete(csvFile);

fprintf(['....PRESS SUBMIT AFTER ADDING 2 TAGS TO THE FIRST EVENT' ...
    ' (1|1|1) AND 2 TAGS TO THE FOURTH EVENT (2|1|3) \n']);
fprintf(['There should be 2 more tags and an updated description added' ...
    ' to the first event (1|1|1)']);
csvFile = 'testcsv.csv';
tagcsv(values.efile3, 'RewriteFile', csvFile);
obj1 = csvMap(csvFile);
values1 = obj1.getValues();
header1 = obj1.getHeader();
tagRow1 = values1{2};
tagRow2 = values1{3};
tagRow3 = values1{6};
tagRow4 = values1{7};
tags1 = strsplit(tagRow1{4}, '|');
tags2 = strsplit(tagRow2{4}, '|');
tags3 = strsplit(tagRow3{4}, '|');
tags4 = strsplit(tagRow4{4}, '|');
assertEqual(header1{4}, 'Tags');
assertTrue(isequal(length(tags1),2) && isequal(length(tags2),2));
assertTrue(isequal(length(tags3),2) && isequal(length(tags4),2));
assertEqual(tags1, tags2);
assertEqual(tags3, tags4);
delete(csvFile);