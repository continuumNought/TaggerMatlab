function createdbc(credPath, sqlFile)
% Takes a property file containing the database credentials and a sql
% file and creates a community tagger database.
parser = inputParser;
parser.addRequired('credPath', @(x) (~isempty(x) && ischar(x)));
parser.addRequired('sqlFile', @(x) (~isempty(x) && ischar(x)));
parser.parse(credPath, sqlFile);
DB = edu.utsa.tagger.database.TagsDBManager(parser.Results.credPath);
DB.setupDatabase(which(parser.Results.sqlFile));
end

