function createdbc(credPath, varargin)
% Takes a property file containing the database credentials and a sql
% file and creates a community tagger database.
parser = inputParser;
parser.addRequired('credPath', @(x) (~isempty(x) && ischar(x)));
parser.addOptional('SqlFile', 'tags.sql', @(x) (~isempty(x) && ischar(x)));
parser.parse(credPath, varargin{:});
p = parser.Results;
DB = edu.utsa.tagger.database.TagsDBManager(p.credPath);
DB.setupDatabase(which(p.SqlFile));
DB.getDBCon();
DB.close();
end

