function createdbc(credPath, varargin)
% Creates a ctagger database from a property file 
parser = inputParser;
parser.addRequired('credPath', @(x) (~isempty(x) && ischar(x)));
parser.addOptional('SqlFile', 'tags.sql', @(x) (~isempty(x) && ischar(x)));
parser.parse(credPath, varargin{:});
p = parser.Results;
edu.utsa.tagger.database.ManageDB.createDatabase(p.credPath, ...
    which(p.SqlFile));
end

