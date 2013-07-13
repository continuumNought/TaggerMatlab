function test_suite = test_tagstudy_input%#ok<STOUT>
initTestSuite;

function test_valid()  %#ok<DEFNU>
% Unit test for tagstudy_input 
fprintf('Testing tagstudy_input\n');
fprintf('....REQUIRES USER INPUT\n');
fprintf('PRESS the CANCEL BUTTON\n');
[studyFile,baseMapFile, dbCredsFile, preservePrefix, ...
rewriteOption, saveAll, saveMapFile, selectOption, useGUI, cancelled] =  ...
    tagstudy_input();
assertTrue(isempty(studyFile));
assertTrue(isempty(baseMapFile));
assertTrue(isempty(dbCredsFile));
assertTrue(~preservePrefix);
assertTrue(strcmpi(rewriteOption, 'Both'));
assertTrue(saveAll);
assertTrue(isempty(saveMapFile));
assertTrue(selectOption);
assertTrue(useGUI);
assertTrue(cancelled);

fprintf('....REQUIRES USER INPUT\n');
fprintf('PRESS the OKAY BUTTON WITHOUT CHANGING ANYTHING\n');
[studyFile,baseMapFile, dbCredsFile, preservePrefix, ...
    rewriteOption, saveAll, saveMapFile, selectOption, useGUI, cancelled] =  ...
    tagstudy_input();
assertTrue(isempty(studyFile));
assertTrue(isempty(baseMapFile));
assertTrue(isempty(dbCredsFile));
assertTrue(~preservePrefix);
assertTrue(strcmpi(rewriteOption, 'Both'));
assertTrue(saveAll);
assertTrue(isempty(saveMapFile));
assertTrue(selectOption);
assertTrue(useGUI);
assertTrue(~cancelled);

fprintf('....REQUIRES USER INPUT\n');
fprintf('PRESS the OKAY BUTTON AFTER SELECTING ALL FILES\n');
[studyFile,baseMapFile, dbCredsFile, preservePrefix, ...
    rewriteOption, saveAll, saveMapFile, selectOption, useGUI, cancelled] =  ...
    tagstudy_input();
assertTrue(~isempty(studyFile));
assertTrue(~isempty(baseMapFile));
assertTrue(~isempty(dbCredsFile));
assertTrue(~preservePrefix);
assertTrue(strcmpi(rewriteOption, 'Both'));
assertTrue(saveAll);
assertTrue(~isempty(saveMapFile));
assertTrue(selectOption);
assertTrue(useGUI);
assertTrue(~cancelled);