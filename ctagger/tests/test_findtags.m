function test_suite = test_findtags%#ok<STOUT>
initTestSuite;

function values = setup %#ok<DEFNU>
typeValues = ['RT,User response,' ...
        '/Time-Locked Event/Stimulus/Visual/Shape/Ellipse/Circle,' ...
        '/Time-Locked Event/Stimulus/Visual/Uniform Color/Black;' ...
        'Trigger,User stimulus,,;Missed,User failed to respond,'];
codeValues = ['1,User response,' ...
        '/Time-Locked Event/Stimulus/Visual/Shape/Ellipse/Circle,' ...
        '/Time-Locked Event/Stimulus/Visual/Uniform Color/Black;' ...
        '2,User stimulus,,;3,User failed to respond,'];
% Read in the HED schema
latestHed = 'HEDSpecification1.3.xml';
values.data.etc.tags.xml = fileread(latestHed);
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

types = {'RT', 'Trigger', 'Missed'};
eStruct = struct('field', 'type', 'values', 'def');
tags = {'/Time-Locked Event/Stimulus/Visual/Shape/Ellipse/Circle', ...
        '/Time-Locked Event/Stimulus/Visual/Fixation Point', ...
        '/Time-Locked Event/Stimulus/Visual/Uniform Color/Black'};
sE = struct('label', types, 'description', types, 'tags', '');
sE(1).tags = tags;
eStruct.values = sE;
eJSON1 = savejson('', eStruct);
values.eStruct1 = eStruct;
values.eJSON1 = eJSON1;
load EEGEpoch.mat;
values.EEGEpoch = EEGEpoch;

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test

function testValidValues(values)  %#ok<DEFNU>
% Unit test for findtags
fprintf('\nUnit tests for findtags\n');
fprintf('It should tag a data set that has a map but no events\n');
dTags = findtags(values.data);
assertTrue(isa(dTags, 'fieldMap'));
fields = dTags.getFields();
assertEqual(length(fields), 3);
for k = 1:length(fields)
    assertTrue(isa(dTags.getMap(fields{k}), 'tagMap'));
end

fprintf('It should return a tag map for an EEG structure that hasn''t been tagged\n');
assertTrue(~isfield(values.EEGEpoch.etc, 'tags'));
dTags = findtags(values.EEGEpoch);
events = dTags.getMaps();
assertEqual(length(events), 2);
assertTrue(~isempty(dTags.getXml()));
fields = dTags.getFields();
assertEqual(length(fields), 2);
assertTrue(strcmpi(fields{1}, 'position'));
assertTrue(strcmpi(fields{2}, 'type'));

fprintf('It should work if EEG doesn''t have .etc field\n');
EEG1 = values.EEGEpoch;
EEG1 = rmfield(EEG1, 'etc');
dTags1 = findtags(EEG1);
events1 = dTags1.getMaps();
assertEqual(length(events1), 2);
assertTrue(~isempty(dTags1.getXml()));
fprintf('It should work if EEG has an empty .etc field\n');
EEG2 = values.EEGEpoch;
EEG2.etc = '';
dTags2 = findtags(EEG2);
events2 = dTags2.getMaps();
assertEqual(length(events2), 2);
assertTrue(~isempty(dTags2.getXml()));
fprintf('It should work if EEG has a non-structure .etc field\n');
EEG3 = values.EEGEpoch;
EEG3.etc = 'This is a test';
dTags3 = findtags(EEG3);
events3 = dTags3.getMaps();
assertEqual(length(events3), 2);
assertTrue(~isempty(dTags3.getXml()));
fprintf('It should work if the EEG has already been tagged\n');
dTags4 = findtags(values.data);
events4 = dTags4.getMaps();
assertEqual(length(events4), 3);
assertTrue(~isempty(dTags4.getXml()));
fields4 = dTags4.getFields();
assertEqual(length(fields4), 3);
assertTrue(strcmpi(fields4{1}, 'code'));
assertTrue(strcmpi(fields4{2}, 'group'));
assertTrue(strcmpi(fields4{3}, 'type'));

function testMultipleFields(values)  %#ok<DEFNU>
% Unit test for findtags
fprintf('\nUnit tests for findtags with multiple field combinations\n');
fprintf('It should tag when the epoch field is not excluded\n');
assertTrue(~isfield(values.EEGEpoch.etc, 'tags'));
dTags = findtags(values.EEGEpoch, 'ExcludeFields', {'latency', 'urevent'});
values1 = dTags.getMaps();
assertEqual(length(values1), 3);
e1 = values1{1}.getStruct();
assertTrue(strcmpi(e1.field, 'epoch'));
assertEqual(length(e1.values), 80);
e2 = values1{2}.getStruct();
assertTrue(strcmpi(e2.field, 'position'));
assertEqual(length(e2.values), 2);
e3 = values1{3}.getStruct();
assertTrue(strcmpi(e3.field, 'type'));
assertEqual(length(e3.values), 2);

function testEmpty(values)  %#ok<INUSD,DEFNU>
% Unit test for findtags
fprintf('\nUnit tests for findtags for empty argument\n');
fprintf('It should return empty map when input is empty\n');
dTags = findtags('');
assertTrue(isa(dTags, 'fieldMap'));
dFields = dTags.getFields();
assertTrue(isempty(dFields));

function testFindTags(values) %#ok<DEFNU>
% Unit test for fieldMap getTags method
fprintf('\nUnit tests for fieldMap getTags method\n');

fprintf('It should get the right tags for fields that exist \n');
fMap = findtags(values.data);
tags1 = fMap.getTags('type', 'RT');
assertEqual(length(tags1), 2);
tags2 = fMap.getTags('type', 'Trigger');
assertTrue(isempty(tags2));
tags3 = fMap.getTags('code', '1');
assertEqual(length(tags3), 2);