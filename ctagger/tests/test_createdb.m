function test_suite = test_createdb%#ok<STOUT>
initTestSuite;

function values = setup %#ok<STOUT,DEFNU>

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test
function test_createdb
createdb(dbname, hostname, port, username, password, varargin)