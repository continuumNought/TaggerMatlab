function test_suite = test_tagdlg%#ok<STOUT>
initTestSuite;

function test_valid()  %#ok<DEFNU>
% % Unit test for cTagger tagEEGDIR static method 
validValues = {'Tag', 'Exclude', 'Cancel'};
fprintf('\nUnit tests for tagdlg require user intervention\n');

fprintf('It should work for 1 value\n');
response = tagdlg('type', 'trigger');
fprintf('...it responded with %s\n', response);
assertTrue(sum(strcmpi(validValues, response)) == 1);

fprintf('It should work for maximum number of values\n');
response = tagdlg('position', ...
    {'trigger1', 'trigger2', 'trigger3', 'trigger4', 'trigger5', ...
    'trigger6', 'trigger7', 'trigger8', 'trigger9', 'trigger10'});
fprintf('...it responded with %s\n', response);
assertTrue(sum(strcmpi(validValues, response)) == 1);

fprintf('It should work with more than the maximum number of values\n');
response = tagdlg('target', ...
    {'trigger1', 'trigger2', 'trigger3', 'trigger4', 'trigger5', ...
    'trigger6', 'trigger7', 'trigger8', 'trigger9', 'trigger10', ...
    'trigger11', 'trigger12', 'trigger13', 'trigger14', 'trigger15'});
fprintf('...it responded with %s\n', response);
assertTrue(sum(strcmpi(validValues, response)) == 1);

fprintf('It should work with no values\n');
response = tagdlg('target', '');
fprintf('...it responded with %s\n', response);
assertTrue(sum(strcmpi(validValues, response)) == 1);

fprintf('It should work with an empty cell array\n');
response = tagdlg('target', {});
fprintf('...it responded with %s\n', response);
assertTrue(sum(strcmpi(validValues, response)) == 1);

fprintf('It should work with an empty field name\n');
response = tagdlg('', {});
fprintf('...it responded with %s\n', response);
assertTrue(sum(strcmpi(validValues, response)) == 1);