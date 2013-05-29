function test_suite = test_tageeg_input%#ok<STOUT>
initTestSuite;

function test_valid()  %#ok<DEFNU>
% Unit test for cTagger tageeg_input 
fprintf('Testing tageeg_input....REQUIRES USER INPUT\n');
fprintf('PRESS the CANCEL BUTTON\n');
[baseMapFile,  dbCredsFile, preservePrefix, ...
    rewriteOption, saveMapFile, selectOption, useGUI, cancelled] ...
    = tageeg_input();
assertTrue(isempty(baseMapFile));
assertTrue(isempty(dbCredsFile));
assertTrue(~preservePrefix);
assertTrue(strcmpi(rewriteOption, 'Both'));
assertTrue(isempty(saveMapFile));
assertTrue(selectOption);
assertTrue(useGUI);
assertTrue(cancelled);

fprintf('PRESS the OKAY BUTTON\n');
[baseMapFile,  dbCredsFile, preservePrefix, ...
    rewriteOption, saveMapFile, selectOption, useGUI, cancelled] ...
    = tageeg_input();
assertTrue(isempty(baseMapFile));
assertTrue(isempty(dbCredsFile));
assertTrue(~preservePrefix);
assertTrue(strcmpi(rewriteOption, 'Both'));
assertTrue(isempty(saveMapFile));
assertTrue(selectOption);
assertTrue(useGUI);
assertTrue(~cancelled);