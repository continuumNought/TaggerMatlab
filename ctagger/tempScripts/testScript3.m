%% 
HEDXML = fileread('HEDSpecification1.3.xml');
HEDSch = fileread('HEDSchema.xsd');
edu.utsa.tagger.database.XMLGenerator.validateSchemaString(HEDXML, HEDSch);