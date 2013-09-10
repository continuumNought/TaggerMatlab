function test_suite = test_dbcreds%#ok<STOUT>
initTestSuite;

function testValid()  %#ok<DEFNU>
% Unit test for dbcreds
    fprintf('\nUnit tests for dbcreds creation\n');
    fprintf('It should create a property file\n');
    fprintf('....REQUIRES USER INPUT\n');
    fprintf('PRESS OKAY AFTER ENTERING SAVE PROP PATH \n');
    configProps = dbcreds();
    assertTrue(~isempty(configProps));
    assertTrue(exist(configProps, 'file') ~= 0);  
 