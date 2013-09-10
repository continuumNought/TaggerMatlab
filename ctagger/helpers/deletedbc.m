function deletedbc(credPath)
% Creates a ctagger database from a property file 
parser = inputParser;
parser.addRequired('credPath', @(x) (~isempty(x) && ischar(x)));
parser.parse(credPath);
p = parser.Results;
edu.utsa.tagger.database.ManageDB.deleteDatabase(p.credPath);
end