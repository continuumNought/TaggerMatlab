function test_suite = test_tagcsv%#ok<STOUT>
initTestSuite;

function values = setup %#ok<STOUT,DEFNU>
setup_tests;

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test


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

function test_tagcsvRewrite(values)  %#ok<DEFNU>
%Unit test for tagcsv with rewrite file 
fprintf('\nUnit tests for tagcsv with rewrite file\n');

fprintf(['It should work with RewriteFile as an argument without a' ...
    ' tags column specified\n']);
fprintf('....PRESS SUBMIT WITHOUT TAGGING FOR EACH GUI\n');
fprintf('The csv rewrite file should not have a tags column');
obj1 = csvMap(values.efile2);
csvFile = 'testcsv.csv';
tagcsv(values.efile2, 'RewriteFile', csvFile);
obj2 = csvMap(csvFile);
header1 = obj1.getHeader();
header2 = obj2.getHeader();
values1 = obj1.getValues();
values2 = obj2.getValues();
assertTrue(exist(csvFile,'file') > 0)
assertEqual(length(values1{1}), length(values2{1})); 
assertEqual(length(header1), length(header2));
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
assertTrue(exist(csvFile,'file') > 0)
assertEqual(length(header1) + 1, length(header2));
assertEqual(header2{4}, 'Tags');
delete(csvFile);

fprintf(['It should work with RewriteFile as an argument with a tags ' ...
    ' column specified\n']);
fprintf(['....PRESS SUBMIT AFTER ADDING A DESCRIPTION TO THE FIRST EVENT' ...
    ' (1|1|1)\n']);
fprintf('The csv rewrite file should have a tags column');
obj1 = csvMap(values.efile2);
csvFile = 'testcsv.csv';
tagcsv(values.efile2, 'RewriteFile', csvFile, 'DescriptionColumn', 4);
obj2 = csvMap(csvFile);
header1 = obj1.getHeader();
header2 = obj2.getHeader();
assertTrue(exist(csvFile,'file') > 0)
assertEqual(length(header1) + 1, length(header2));
assertEqual(header2{4}, 'Description');
delete(csvFile);

fprintf(['It should work with RewriteFile as an argument with existing' ...
    ' tags as well as event, tag, and description columns specified\n']);
fprintf('....PRESS SUBMIT WITHOUT TAGGING FOR EACH GUI\n');
fprintf(['The csv rewrite file should have the same number of columns'  ...
    ' as the csv file passed in to create the csvMap\n']);
tagcsv(values.efile1, 'EventColumns', [1, 3, 5], 'DescriptionColumn', ...
    8,'TagsColumn', 7, 'RewriteFile', csvFile);
obj3 = csvMap(values.efile1);
obj4 = csvMap(csvFile);
header3 = obj3.getHeader();
header4 = obj4.getHeader();
values3 = obj3.getValues();
values4 = obj4.getValues();
assertTrue(exist(csvFile,'file') > 0)
assertEqual(length(values3{1}), length(values4{1})); 
assertEqual(length(header3), length(header4));
delete(csvFile);

fprintf(['....PRESS SUBMIT AFTER ADDING 2 TAGS TO THE FIRST EVENT' ...
    ' (1|1|1)\n']);
fprintf('There should be 2 tags added to the first event (1|1|1)');
tagcsv(values.efile1, 'EventColumns', [1, 3, 5], 'DescriptionColumn', ...
    8,'TagsColumn', 7, 'RewriteFile', csvFile);
obj5 = csvMap(values.efile1);
obj6 = csvMap(csvFile);
values5 = obj5.getValues();
values6 = obj6.getValues();
values5Row1 = values5{2};
tags1 = strsplit(values5Row1{7}, '|');
values6Row1 = values6{2};
tags2 = strsplit(values6Row1{7}, '|');
assertEqual(length(tags1) + 2, length(tags2)); 
delete(csvFile);