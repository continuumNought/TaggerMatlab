function test_suite = test_tageeg%#ok<STOUT>
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
values.xml = fileread(latestHed);
values.type = typeValues;
values.code = codeValues;
values.group = codeValues;
values.map1 = fieldMap('XML', values.xml);
s1 = tagMap.text2Values(values.type);
values.map1.addValues('type', s1);
s2 = tagMap.text2Values(values.code);
values.map1.addValues('code', s2);
values.map1.addValues('group', s2);
values.data.etc.tags = values.map1.getStruct();
values.data.event = struct('type', {'RT', 'Trigger'}, 'code', {'1', '2'});
load EEGEpoch.mat;
values.EEGEpoch = EEGEpoch;

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test

function testValidValues(values)  %#ok<DEFNU>
% Unit test for findtags
fprintf('\nUnit tests for tageeg\n');
fprintf('It should tag a data set that has a map but no events\n');
fName = 'temp1.mat';
x = values.data;
[y, fMap, excluded] = tageeg(x, 'RewriteOption', 'both', ...
        'UseGui', false, 'SaveMapFile', fName, 'SelectOption', false);
assertEqual(length(excluded), 5);
assertTrue(isa(fMap, 'fieldMap'));
assertTrue(isfield(y.etc, 'tags'));
assertTrue(isfield(y.etc.tags, 'xml'));
assertEqual(length(fieldnames(y.etc.tags)), 2);
assertTrue(isfield(y.etc.tags, 'map'));
assertEqual(length(fieldnames(y.etc.tags.map)), 2);
fNew = fieldMap.loadFieldMap(fName);
assertTrue(isa(fNew, 'fieldMap'));
delete(fName);

function testSelectTags(values)  %#ok<DEFNU>
% Unit tests for tag_eeg selecting which fields
fprintf('It should allow user to select the types to tag\n');
fprintf('....REQUIRES USER INPUT\n');
fprintf('PRESS EXCLUDE BUTTON ONCE FOLLOWED BY TAG\n');
fprintf('....you should not see a tagging GUI for code\n');
fprintf('....PRESS SUBMIT WITHOUT TAGGING FOR EACH GUI\n');
fName = 'temp2.mat';
x = values.data;
[y, fMap, excluded] = tageeg(x, 'RewriteOption', 'both', ...
        'UseGui', true, 'SaveMapFile', fName, 'SelectOption', true);
assertTrue(isa(fMap, 'fieldMap'));
assertTrue(isfield(y.etc, 'tags'));
assertTrue(isfield(y.etc.tags, 'xml'));
assertEqual(length(fieldnames(y.etc.tags)), 2);
assertTrue(isfield(y.etc.tags, 'map'));
assertEqual(length(fieldnames(y.etc.tags.map)), 2);
fNew = fieldMap.loadFieldMap(fName);
assertTrue(isa(fNew, 'fieldMap'));
assertEqual(length(excluded), 6);
delete(fName);

function testUseGUI(values)  %#ok<DEFNU>
fprintf('It should allow user to use the GUI to tag\n');
fprintf('....REQUIRES USER INPUT\n');
fprintf('PRESS the SUBMIT button exactly once otherwise CANCEL\n');
fName = 'temp2.mat';
x = values.data;
[y, fMap, excluded] = tageeg(x, 'RewriteOption', 'both', ...
        'UseGui', true, 'SaveMapFile', fName, 'SelectOption', false);
assertTrue(isa(fMap, 'fieldMap'));
fields = fMap.getFields();
assertEqual(sum(strcmpi(fields, 'code')), 1);
assertEqual(sum(strcmpi(fields, 'group')), 1);
assertEqual(sum(strcmpi(fields, 'type')), 1);
assertTrue(isfield(y.etc, 'tags'));
assertTrue(isfield(y.etc.tags, 'xml'));
assertEqual(length(fieldnames(y.etc.tags)), 2);
assertEqual(length(excluded), 5);


function testReuse(values)  %#ok<DEFNU>
fprintf('It should correctly tag a dataset multiple times\n');
fprintf('....REQUIRES USER INPUT\n');
fprintf('PRESS THE SUBMIT BUTTON ONCE, THEN CANCEL\n');
fName = 'temp3.mat';
x = values.data;
[y1, fMap, excluded] = tageeg(x, 'RewriteOption', 'both', ...
        'UseGui', true, 'SaveMapFile', fName, 'SelectOption', false);
assertTrue(isa(fMap, 'fieldMap'));
fields = fMap.getFields();
assertEqual(sum(strcmpi(fields, 'code')), 1);
assertEqual(sum(strcmpi(fields, 'group')), 1);
assertEqual(sum(strcmpi(fields, 'type')), 1);
assertTrue(isfield(y1.etc, 'tags'));
assertTrue(isfield(y1.etc.tags, 'xml'));
assertEqual(length(fieldnames(y1.etc.tags)), 2);
assertEqual(length(excluded), 5);
fprintf('Now retagging... there should be 3 values for code\n');
fprintf('PRESS THE SUBMIT BUTTON ONCE, THEN CANCEL\n');
fName = 'temp3.mat';
[y2, fMap, excluded] = tageeg(y1, 'RewriteOption', 'both', ...
        'UseGui', true, 'SaveMapFile', fName, 'SelectOption', false);
assertEqual(sum(strcmpi(fields, 'code')), 1);
assertEqual(sum(strcmpi(fields, 'group')), 1);
assertEqual(sum(strcmpi(fields, 'type')), 1);
assertTrue(isfield(y2.etc, 'tags'));
assertTrue(isfield(y2.etc.tags, 'xml'));
assertEqual(length(fieldnames(y2.etc.tags)), 2);
assertEqual(length(excluded), 5);