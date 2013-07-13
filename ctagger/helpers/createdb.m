function createdb(dbname, hostname, port, username, password, varargin)
% Create a database using username and password
parser = inputParser();
parser.addRequired('dbname', @(x) (~isempty(x) && ischar(x)));
parser.addRequired('hostname', @(x) (~isempty(x) && ischar(x)));
parser.addRequired('port', @(x) isnumeric(x) && isscalar(x));
parser.addRequired('username', @(x) (~isempty(x) && ischar(x)));
parser.addRequired('password', @(x) (~isempty(x) && ischar(x)));
parser.addOptional('sqlFile', 'tags.sql', @(x) (~isempty(x) && ischar(x)));
parser.parse(dbname, hostname, port, username, password, varargin{:});
p = parser.Results;
DB = edu.utsa.tagger.database.TagsDBManager(p.dbname, p.hostname, ...
    num2str(p.port), p.username, p.password);
DB.setupDatabase(which(p.sqlFile));
DB.getDBCon();
DB.close();
end

