function fMap = editMapDb(fMap, varargin)
%EDITMAPDB Summary of this function goes here
%   Detailed explanation goes here
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
        DB = edu.utsa.tagger.database.TagsDBManager(p.DbCreds);
        DB.getDBCon();
        dbXML = char(DB.generateXML());
        fMap.mergeXml(dbXML);
        usingDB = true;
        DB.close();
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
        dbCon = DB.getDBCon();
        edu.utsa.tagger.database.TagsUpdate.updateXML(dbCon, ...
            fMap.getXml());
        keys = fMap.getFields();
        numKeys = length(keys);
        for a = 1:numKeys
            oldtMap = oldfMap.getMap(keys{a});
            newtMap = fMap.getMap(keys{a});
            oldValues = oldtMap.getValues();
            newValues = newtMap.getValues();
            oldJSON = oldtMap.values2Json(oldValues);
            newJSON = newtMap.values2Json(newValues);
            edu.utsa.tagger.database.TagsUpdate.updateTagCount(dbCon, ...
                oldJSON, newJSON, true);
        end
        DB.close();
    catch ME
        warning('ctagger:connectionfailed', ME.message);
    end
end
end