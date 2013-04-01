function test_suite = testJsonConversion %#ok<STOUT>
initTestSuite;

function values = setup %#ok<DEFNU>
values = '';

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test


function testJsonEvents(values) %#ok<DEFNU>
% Unit test for eventTags constructor valid JSON
fprintf('\nUnit tests for JsonConversion\n');
fprintf('It should convert a structure with empty events\n');
eStruct1.events = '';
Json1 = savejson('', eStruct1);
s1 = loadjson(Json1);
assertTrue(isstruct(s1));
fprintf('It should not work properly for an empty string\n');
Json2 = savejson('', '');
try  
   s1 = loadjson(Json2);
   fail('Can''t retranslate');
catch e
    assertTrue(strcmpi('input file does not exist', e.message));
end
% f = @() loadjson(Json2);
% assertAltExceptionThrown(f, {'exception'});

% Json2 = savejson('', '');
% fprintf('Json2: %s\n', Json2);
% Json3 = savejson('', []);
% Json4 = savejson('', {});
% fprintf('Json3: %s\n', Json3);
% fprintf('Json4: %s\n', Json4);
% 
% 
% s1 = loadjson(Json1);
% s2 = loadjson(Json2);
% s3 = loadjson(Json3);
% s4 = loadjson(Json4);
% fprintf('');
