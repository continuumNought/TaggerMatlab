function createdb(dbname, hostname, port, username, password, varargin)
% Creates a ctagger database
parser = inputParser();
parser.addRequired('dbname', @(x) (~isempty(x) && ischar(x)));
parser.addRequired('hostname', @(x) (~isempty(x) && ischar(x)));
parser.addRequired('port', @(x) isnumeric(x) && isscalar(x));
parser.addRequired('username', @(x) (~isempty(x) && ischar(x)));
parser.addRequired('password', @(x) (~isempty(x) && ischar(x)));
parser.addOptional('sqlFile', 'tags.sql', @(x) (~isempty(x) && ischar(x)));
parser.parse(dbname, hostname, port, username, password, varargin{:});
p = parser.Results;
edu.utsa.tagger.database.ManageDB.createDatabase(p.dbname, p.hostname, ...
    p.port, p.username, p.password, which(p.sqlFile));
end

