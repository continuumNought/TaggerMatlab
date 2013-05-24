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
values.data.etc.tags.map.type = typeValues;
values.data.etc.tags.map.code = codeValues;
values.data.etc.tags.map.group = codeValues;
load EEGEpoch.mat;
values.EEGEpoch = EEGEpoch;

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test

function testValidValues(values)  %#ok<DEFNU>
% Unit test for findtags
fprintf('\nUnit tests for findtags\n');
fprintf('It should tag a data set that has a map but no events\n');
dTags = findtags(values.data);
assertTrue(isa(dTags, 'typeMap'));
fields = dTags.getFields();
assertEqual(length(fields), 3);
for k = 1:length(fields)
    assertTrue(isa(dTags.getEvents(fields{k}), 'tagMap'));
end

fprintf('It should return a tag map for an EEG structure that hasn''t been tagged\n');
assertTrue(~isfield(values.EEGEpoch.etc, 'tags'));
dTags = findtags(values.EEGEpoch);
events = dTags.getTagMaps();
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
events1 = dTags1.getTagMaps();
assertEqual(length(events1), 2);
assertTrue(~isempty(dTags1.getXml()));
fprintf('It should work if EEG has an empty .etc field\n');
EEG2 = values.EEGEpoch;
EEG2.etc = '';
dTags2 = findtags(EEG2);
events2 = dTags2.getTagMaps();
assertEqual(length(events2), 2);
assertTrue(~isempty(dTags2.getXml()));
fprintf('It should work if EEG has a non-structure .etc field\n');
EEG3 = values.EEGEpoch;
EEG3.etc = 'This is a test';
dTags3 = findtags(EEG3);
events3 = dTags3.getTagMaps();
assertEqual(length(events3), 2);
assertTrue(~isempty(dTags3.getXml()));
fprintf('It should work if the EEG has already been tagged\n');
dTags4 = findtags(values.data);
events4 = dTags4.getTagMaps();
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
events = dTags.getTagMaps();
assertEqual(length(events), 3);
e1 = events{1}.getStruct();
assertTrue(strcmpi(e1.field, 'epoch'));
assertEqual(length(e1.events), 80);
e2 = events{2}.getStruct();
assertTrue(strcmpi(e2.field, 'position'));
assertEqual(length(e2.events), 2);
e3 = events{3}.getStruct();
assertTrue(strcmpi(e3.field, 'type'));
assertEqual(length(e3.events), 2);

