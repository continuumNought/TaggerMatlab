function test_suite = test_createdbc%#ok<STOUT>
initTestSuite;

function tStruct  = setup %#ok<DEFNU>
tStruct = struct('configPath', fullfile(pwd, 'dbcreds.txt'), 'dbname', ...
    'ctagger', 'hostname', 'localhost', 'port', '5432', 'username', ...
    'postgres', 'password', 'admin');
edu.utsa.tagger.database.TagsDBManager.createCredentials(...
    tStruct.configPath, tStruct.dbname, tStruct.hostname, tStruct.port, ...
    tStruct.username, tStruct.password);

function teardown(tStruct) %#ok<DEFNU>
% Function executed after each test
delete(tStruct.configPath);

function testValid()  %#ok<DEFNU>
% Unit test for createdb
fprintf('\nUnit tests for createdb\n');
fprintf('It should create a database from property file\n');
fprintf('....REQUIRES USER INPUT\n');
fprintf('PRESS SUBMIT AFTER PATH \n');
credPath = dbcreds();
scriptFilePath = which('tags.sql');
assertTrue(~isempty(credPath));
createdb(credPath, scriptFilePath);
DB = edu.utsa.tagger.database.TagsDBManager(credPath);
assertTrue(~isempty(DB.getDBCon));
DB.close();
