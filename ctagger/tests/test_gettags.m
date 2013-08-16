% function test_suite = test_gettags%#ok<STOUT>
% initTestSuite;
% 
% function values = setup %#ok<DEFNU>
% setup_tests;
% 
% function teardown(values) %#ok<INUSD,DEFNU>
% % Function executed after each test
% 
% function testValidValues(values)  %#ok<DEFNU>
% % Unit test for gettags
% fprintf('\nUnit tests for gettags\n');
% fprintf('It should tag with the default columns\n');
% dTags = gettags(values.data);
% assertTrue(isa(dTags, 'fieldMap'));
% fields = dTags.getFields();
% assertEqual(length(fields), 3);
% for k = 1:length(fields)
%     assertTrue(isa(dTags.getMap(fields{k}), 'tagMap'));
% end

