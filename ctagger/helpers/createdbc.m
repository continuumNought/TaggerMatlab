function createdbc(credPath, sqlFile, varargin)
% Takes a property file containing the database credentials and a sql
% file and creates a community tagger database.
parser = inputParser;
parser.addRequired('credPath', @(x) (~isempty(x) && ischar(x)));
parser.addRequired('sqlFile', @(x) (~isempty(x) && ischar(x)));
parser.parse(credPath, sqlFile);
p = parser.Results;
DB = edu.utsa.tagger.database.TagsDBManager(p.credPath);
DB.setupDatabase(which(p.sqlFile));
DB.getDBCon();
DB.close();
end

