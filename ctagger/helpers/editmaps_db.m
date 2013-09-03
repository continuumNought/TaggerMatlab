% editmaps_db
% Allows a user to selectively edit the tags using the ctagger database 
% 
function fMap = editmaps_db(fMap, varargin)
parser = inputParser;
parser.addRequired('fMap', @(x) (~isempty(x) && isa(x, 'fieldMap')));
parser.addParamValue('DbCreds', '', @(x)(isempty(x) || (ischar(x))));
parser.addParamValue('PreservePrefix', false, @islogical);
parser.addParamValue('Synchronize', true, @islogical);
parser.addParamValue('UseGui', true, @islogical);
parser.parse(fMap, varargin{:});
p = parser.Results;
usingDB = false;
if ~isempty(p.DbCreds)
    try
        DB = edu.utsa.tagger.database.ManageDB(p.DbCreds);
        dbCon = DB.getConnection();
        fMap.mergeDBXml(dbCon, false);
        usingDB = true;
        oldfMap = fMap.clone();
    catch ME %#ok<NASGU>
        choice = questdlg(['Database connection failed. Would you like' ...
            ' to continue without the database?'], 'Yes', 'No');
        switch choice
            case 'Yes'
            case 'No'
                return;
        end
    end
end

if p.UseGui
    fprintf('\n---Now choose tags for each field value---\n');
    fMap = editmaps(fMap, 'PreservePrefix', p.PreservePrefix, ...
        'Synchronize', p.Synchronize);
end

if usingDB
    try
        fMap.mergeDBXml(dbCon, true);
        keys = fMap.getFields();
        numKeys = length(keys);
        for a = 1:numKeys
            oldtMap = oldfMap.getMap(keys{a});
            newtMap = fMap.getMap(keys{a});
            oldValues = oldtMap.getValues();
            newValues = newtMap.getValues();
            oldJSON = oldtMap.values2Json(oldValues);
            newJSON = newtMap.values2Json(newValues);
            Events = edu.utsa.tagger.database.Events(dbCon);
            Events.updateTagCount(oldJSON, newJSON, true);
        end
        DB.close();
    catch ME
        warning('ctagger:connectionfailed', ME.message);
    end
end
end