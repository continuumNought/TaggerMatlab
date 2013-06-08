function test_suite = test_dbcreds%#ok<STOUT>
initTestSuite;

function testValid()  %#ok<DEFNU>
% Unit test for editmaps
    fprintf('\nUnit tests for editmaps increase indent\n');
    fprintf('It should work present multiple GUIs\n');
    fprintf('....REQUIRES USER INPUT\n');
    fprintf('PRESS SUBMIT AFTER PATH \n');
    configProps = dbcreds();
    assertTrue(~isempty(configProps));
  
 