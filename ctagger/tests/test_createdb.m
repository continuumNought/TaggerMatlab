function test_suite = test_createdb%#ok<STOUT>
initTestSuite;

function teardown() %#ok<DEFNU>
deletedb('testdb', 'localhost', 5432, 'postgres', 'admin');


function test_createdb_default()  %#ok<DEFNU>
createdb('testdb', 'localhost', 5432, 'postgres', 'admin');
