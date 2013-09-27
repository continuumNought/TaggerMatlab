function test_suite = test_createdbc%#ok<STOUT>
initTestSuite;

function teardown() %#ok<DEFNU>
deletedbc(which('dbcreds.txt'));


function test_createdb_default()  %#ok<DEFNU>
createdbc(which('dbcreds.txt'));
