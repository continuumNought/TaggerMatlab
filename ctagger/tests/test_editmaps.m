function test_suite = test_editmaps%#ok<STOUT>
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
values.xml = fileread(latestHed);
values.type = typeValues;
values.code = codeValues;
values.group = codeValues;
values.map1 = fieldMap('XML', values.xml);
s1 = tagMap.text2Values(values.type);
values.map1.addValues('type', s1);

values.map2 = fieldMap('XML', values.xml);
values.map2.addValues('type', s1);
s2 = tagMap.text2Values(values.code);
values.map2.addValues('code', s2);
values.map2.addValues('group', s2);

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test


function testSubmit(values)  %#ok<DEFNU>
% Unit test for editmaps
fprintf('\nUnit tests for editmaps normal execution\n');
fprintf('\nIt should work when there is a single field\n');
fprintf('....REQUIRES USER INPUT\n');
fprintf('PRESS SUBMIT AFTER NO CHANGES\n');
fMap = values.map1;
fMap1 = editmaps(fMap.clone());
assertEqual(fMap1, values.map1);

fprintf('\nIt should modify the number of tags\n');
fprintf('....REQUIRES USER INPUT\n');
fprintf('PRESS SUBMIT AFTER ADDING 2 TAGS TO SOME VALUE\n');
fMap2 = editmaps(fMap.clone());
events1 = fMap.getValues('type');
count1 = 0;
for k = 1:length(events1)
    etags = events1{k}.tags;
    if ischar(etags) && ~isempty(etags)
        count1 = count1 + 1;
    else
        count1 = count1 + length(etags);
    end
end
fprintf('\nIt should not modify the number of type values\n');
events2 = fMap2.getValues('type');
assertEqual(length(events2), 3);

fprintf('\nIt should increase the number of tags by 2\n');
count2 = 0;
for k = 1:length(events2)
    etags = events2{k}.tags;
    if ischar(etags) && ~isempty(etags)
        count2 = count2 + 1;
    else
        count2 = count2 + length(etags);
    end
end
assertEqual(count2, count1 + 2);
fprintf('\nIt should not increase the number of type values when edited again\n');
fprintf('....REQUIRES USER INPUT\n');
fprintf('PRESS SUBMIT AFTER ADDING 3 TAGS TO SOME VALUE\n');
fMap3 = editmaps(fMap2);
events3 = fMap3.getValues('type');
count3 = 0;
for k = 1:length(events3)
    etags = events3{k}.tags;
    if ischar(etags) && ~isempty(etags)
        count3 = count3 + 1;
    else
        count3 = count3 + length(etags);
    end
end
assertEqual(count3, count2 + 3);

function testMultipleFields(values)  %#ok<DEFNU>
% Unit test for editmaps
fprintf('\nUnit tests for editmaps multiple fields\n');
fprintf('\nIt should work present multiple GUIs\n');
fprintf('....REQUIRES USER INPUT\n');
fprintf('PRESS SUBMIT BUTTON WITH NO CHANGES\n');
fprintf('PRESS CYCLE THROUGH 3 GUIs\n');
fMap1 = editmaps(values.map2);
assertEqual(fMap1, values.map2);

function testCancel(values)  %#ok<DEFNU>
% Unit test for editmaps
fprintf('\nUnit tests for editmaps cancel\n');
fprintf('\nIt should work present multiple GUIs\n');
fprintf('....REQUIRES USER INPUT\n');
fprintf('PRESS CANCEL BUTTON\n');
fMap1 = editmaps(values.map2);
assertEqual(fMap1, values.map2);