function createdbc(credPath, sqlFile, varargin)
% Takes a property file containing the database credentials and a sql
% file and creates a community tagger database.
parser = inputParser;
parser.addRequired('credPath', @(x) (~isempty(x) && ischar(x)));
parser.addRequired('sqlFile', @(x) (~isempty(x) && ischar(x)));
parser.addOptional('xml','HEDSpecification1.3.xml',  @(x) ...
    (~isempty(x) && ischar(x)));
parser.addOptional('xmlSchema', 'HEDSchema.xsd',  @(x) ...
    (~isempty(x) && ischar(x)));
parser.parse(credPath, sqlFile, varargin{:});
p = parser.Results;
xmlString = fileread(p.xml);
xmlSchemaString = fileread(p.xmlSchema);
sqlFilePath = which(p.sqlFile);
if ~isempty(xmlString)
    edu.utsa.tagger.database.XMLGenerator.validateSchemaString(...
        xmlString, xmlSchemaString);
end
DB = edu.utsa.tagger.database.TagsDBManager(parser.Results.credPath);
DB.setupDatabase(sqlFilePath);
DB.getDBCon();
DB.initializeFromXML(xmlString);
DB.close();
end

