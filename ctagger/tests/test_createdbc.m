function test_suite = test_createdbc%#ok<STOUT>
initTestSuite;

function tStruct  = setup %#ok<DEFNU>
tStruct = struct('credPath', fullfile(pwd, filesep, 'testData', ...
    filesep, 'dbcreds.txt'), 'scriptPath', 'tags.sql', 'dbname', ...
    'ctagger', 'hostname', 'localhost', 'port', '5432', 'username', ...
    'postgres', 'password', ...
    'admin', 'DB', []);
edu.utsa.tagger.database.TagsDBManager.createCredentials(...
    tStruct.credPath, tStruct.dbname, tStruct.hostname, tStruct.port, ...
    tStruct.username, tStruct.password);
tStruct.DB = edu.utsa.tagger.database.TagsDBManager(tStruct.credPath);

function teardown(tStruct) %#ok<DEFNU>
% Function executed after each test
delete(tStruct.credPath);
tStruct.DB.teardownDatabase();

function testValid(tStruct)  %#ok<DEFNU>
% Unit test for createdb
fprintf('\nUnit tests for createdb\n');
fprintf('It should create a database from property file\n');
createdbc(tStruct.credPath, tStruct.scriptPath);
% Get connection for created db
assertTrue(~isempty(tStruct.DB.getDBCon()));

