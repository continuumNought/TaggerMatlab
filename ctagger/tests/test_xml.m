function test_suite = testXMLValidation %#ok<STOUT>
initTestSuite;

function values = setup %#ok<DEFNU>
values.HEDXML = fileread('HED Specification 1.22.xml');
values.SchemaFile = 'G:\CommunityTemp\cTaggerMatlab\xml\HEDSChema.xsd';
values.Schema = fileread('HEDSChema.xsd');
function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test


% function testValid(values) %#ok<DEFNU>
% % Unit test for eventTags constructor valid JSON
% fprintf('\nUnit tests for XML validation using Java libraries\n');
% fprintf('It should correctly validate the default HED hierarchy\n');
% isValid = edu.utsa.tagger.database.XMLGenerator.validateXML(values.HEDXML);
% assertTrue(isValid);


function testValidWithSchema(values) %#ok<DEFNU>
% Unit test for eventTags constructor valid JSON
fprintf('\nUnit tests for XML validation using Java libraries\n');
fprintf('It should correctly validate the default HED hierarchy when a schema is given\n');
try 
    edu.utsa.tagger.database.XMLGenerator.validateSchemaString(values.HEDXML, values.Schema);
    isValid = true;
catch ex
    isValid = false;
end
 assertTrue(isValid);

% function testUpdateSML(values) %#ok<DEFNU>
% % Unit test for eventTags constructor valid JSON
% fprintf('\nUnit tests for XMLGenerator updateXML\n');
% fprintf('It add tags to the XML scheme\n');
% edu.utsa.tagger.database.XMLGenerator.validateSchemaString(values.HEDXML, values.Schema);
% assertTrue(isValid);
