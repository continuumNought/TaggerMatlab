function test_suite = test_tagdir_input%#ok<STOUT>
initTestSuite;

function test_valid()  %#ok<DEFNU>
% Unit test for cTagger tageeg_input 
fprintf('Testing tagdir_input....REQUIRES USER INPUT\n');
fprintf('PRESS the CANCEL BUTTON\n');
 [inDir, baseMapFile, dbCredsFile, doSubDirs, preservePrefix, ...
    rewriteOption, saveMapFile, selectOption, useGUI, cancelled] =  ...
    tagdir_input();
assertTrue(isempty(inDir));
assertTrue(isempty(baseMapFile));
assertTrue(isempty(dbCredsFile));
assertTrue(doSubDirs);
assertTrue(~preservePrefix);
assertTrue(strcmpi(rewriteOption, 'Both'));
assertTrue(isempty(saveMapFile));
assertTrue(selectOption);
assertTrue(useGUI);
assertTrue(cancelled);

fprintf('PRESS the OKAY BUTTON\n');
 [inDir, baseMapFile, dbCredsFile, doSubDirs,  preservePrefix, ...
    rewriteOption, saveMapFile, selectOption, useGUI, cancelled] =  ...
    tagdir_input();
assertTrue(isempty(inDir));
assertTrue(isempty(baseMapFile));
assertTrue(isempty(dbCredsFile));
assertTrue(doSubDirs);
assertTrue(~preservePrefix);
assertTrue(strcmpi(rewriteOption, 'Both'));
assertTrue(isempty(saveMapFile));
assertTrue(selectOption);
assertTrue(useGUI);
assertTrue(~cancelled);