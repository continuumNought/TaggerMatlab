function test_suite = test_pop_tageeg%#ok<STOUT>
initTestSuite;

function values = setup %#ok<DEFNU>
typeValues = ['RT,User response,' ...
        '/Time-Locked Event/Stimulus/Visual/Shape/Ellipse/Circle,' ...
        '/Time-Locked Event/Stimulus/Visual/Uniform Color/Black;' ...
        'Trigger,User stimulus,,;Missed,User failed to respond,'];
codeValues = ['1,User response,' ...
        '/Time-Locked Event/Stimulus/Visual/Shape/Ellipse/Square,' ...
        '/Time-Locked Event/Stimulus/Visual/Uniform Color/Blue;' ...
        '2,User stimulus,,;3,User failed to respond,'];
% Read in the HED schema
latestHed = 'HEDSpecification1.3.xml';
values.data.etc.tags.xml = fileread(latestHed);
map(3) = struct('field', '', 'values', '');
map(1).field = 'type';
map(1).values = typeValues;
map(2).field = 'code';
map(2).values = codeValues;
map(3).field = 'group';
map(3).values = codeValues;
values.data.etc.tags.map = map;
values.data.event = struct('type', {'RT', 'Trigger'}, 'code', {'1', '2'});
load EEGEpoch.mat;
values.EEGEpoch = EEGEpoch;

function test_valid(values)  %#ok<DEFNU>
% Unit test for pop_tageeg
fprintf('Testing pop_tageeg....REQUIRES USER INPUT\n');
fprintf('\nIt should not return anything when the cancel button is pressed\n');
fprintf('PRESS the CANCEL BUTTON\n');
[EEG1, com] = pop_tageeg(values.EEGEpoch);
assertTrue(~isfield(EEG1.etc, 'tags'));
assertTrue(~isfield(EEG1.event(1), 'usertags'));
assertTrue(isempty(com));

fprintf('\nIt should return a command when tagged\n');
fprintf('SET TO USE GUI\n');
fprintf('SET NOT TO PRESERVE PREFIX\n');
fprintf('EXCLUDE POSITION FIELD\n');
fprintf('PRESS THE OKAY BUTTON\n');
fprintf('SELECT TWO OVERLAPPING TAGS FOR ONE VALUE OF TYPE FIELD\n'); 
fprintf('PRESS the SUBMIT BUTTON\n');
[EEG1, com] = pop_tageeg(values.EEGEpoch);
assertTrue(isfield(EEG1.etc, 'tags'));
assertTrue(isfield(EEG1.event(1), 'usertags'));
assertTrue(~isempty(com));