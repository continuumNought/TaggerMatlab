function test_suite = test_typedlg%#ok<STOUT>
initTestSuite;

function test_valid()  %#ok<DEFNU>
% % Unit test for cTagger tagEEGDIR static method 
validValues = {'Tag', 'Skip', 'Cancel', 'Remove', 'Quit'};
fprintf('\nUnit tests for typedlg require user intervention\n');

fprintf('It should work for 1 value\n');
response = typedlg('type', 'trigger');
fprintf('...it responded with %s\n', response);
assertTrue(sum(strcmpi(validValues, response)) == 1);

fprintf('It should work for maximum number of values\n');
response = typedlg('position', ...
    {'trigger1', 'trigger2', 'trigger3', 'trigger4', 'trigger5', ...
    'trigger6', 'trigger7', 'trigger8', 'trigger9', 'trigger10'});
fprintf('...it responded with %s\n', response);
assertTrue(sum(strcmpi(validValues, response)) == 1);

fprintf('It should work with more than the maximum number of values\n');
response = typedlg('target', ...
    {'trigger1', 'trigger2', 'trigger3', 'trigger4', 'trigger5', ...
    'trigger6', 'trigger7', 'trigger8', 'trigger9', 'trigger10', ...
    'trigger11', 'trigger12', 'trigger13', 'trigger14', 'trigger15'});
fprintf('...it responded with %s\n', response);
assertTrue(sum(strcmpi(validValues, response)) == 1);