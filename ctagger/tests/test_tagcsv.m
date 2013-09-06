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

function test_basic(values)  %#ok<DEFNU>
%Unit test for tagcsv for basic stuff
fprintf('\nUnit tests for tagcsv with no write\n');

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

fprintf('It should work with RewriteFile as an argument with no tags\n');
fprintf('....PRESS SUBMIT WITHOUT TAGGING FOR EACH GUI\n');
csvFile = 'testcsv.csv';
tagcsv(values.efile2, 'RewriteFile', csvFile);
obj2 = csvMap(csvFile);
header2 = obj2.getHeader();
assertEqual(header2{end}, 'Tags');
delete(csvFile);




