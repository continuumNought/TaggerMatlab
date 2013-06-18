function createdbc(credPath, scriptPath)
% Takes a property file containing the database credentials and a sql
% file and creates a community tagger database.
parser = inputParser;
parser.addRequired('credPath', @(x) (~isempty(x) && ischar(x)));
parser.addRequired('scriptFilePath', @(x) (~isempty(x) && ischar(x)));
parser.parse(credPath, scriptPath);
DB = edu.utsa.tagger.database.TagsDBManager(parser.Results.credPath);
DB.setupDatabase(parser.Results.scriptFilePath)
end

