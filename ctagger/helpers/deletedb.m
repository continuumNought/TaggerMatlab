function deletedb(dbname, hostname, port, username, password)
parser = inputParser();
parser.addRequired('dbname', @(x) (~isempty(x) && ischar(x)));
parser.addRequired('hostname', @(x) (~isempty(x) && ischar(x)));
parser.addRequired('port', @(x) isnumeric(x) && isscalar(x));
parser.addRequired('username', @(x) (~isempty(x) && ischar(x)));
parser.addRequired('password', @(x) (~isempty(x) && ischar(x)));
parser.parse(dbname, hostname, port, username, password);
p = parser.Results;
edu.utsa.tagger.database.ManageDB.deleteDatabase(p.dbname, p.hostname, ...
    p.port, p.username, p.password);
end
