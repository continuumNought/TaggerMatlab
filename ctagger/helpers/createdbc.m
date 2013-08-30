function createdbc(credPath, varargin)
% Takes a property file containing the database credentials and a sql
% file and creates a community tagger database.
parser = inputParser;
parser.addRequired('credPath', @(x) (~isempty(x) && ischar(x)));
parser.addOptional('SqlFile', 'tags.sql', @(x) (~isempty(x) && ischar(x)));
parser.parse(credPath, varargin{:});
p = parser.Results;
edu.utsa.tagger.database.ManageDB.createDatabase(p.credPath, ...
    which(p.SqlFile));
end

