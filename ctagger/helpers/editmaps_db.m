% editmaps_db
% Allows a user to selectively edit the tags using the ctagger database
%
% Usage:
%   >>  fMap = editmaps_db(fMap)
%   >>  fMap = editmaps_db(fMap, 'key1', 'value1', ...)
%
% Description:
% fMap = editmaps_db(fMap) presents a CTAGGER tagging GUI for each of the
% fields in fMap and allows users to tag, add items to the tag
% hierarchy or add/edit events.
%
% fMap = editmaps_db(fMap, 'key1', 'value1', ...) specifies
% optional name/value parameter pairs:
%
%   'DbCreds'        A property file that contains database credentials
%   'PreservePrefix' If false (default), tags of the same event type that
%                    share prefixes are combined and only the most specific
%                    is retained (e.g., /a/b/c and /a/b become just
%                    /a/b/c). If true, then all unique tags are retained.
%   'Synchronize'    If false (default), the ctagger GUI is run with
%                    synchronization done using the MATLAB pause. If
%                    true, synchronization is done within Java. This
%                    latter option is usually reserved when not calling
%                    the GUI from MATLAB.
%   'UseGui'         If true (default), the CTAGGER GUI is displayed after
%                    initialization
%
% Function documentation:
% Execute the following in the MATLAB command window to view the function
% documentation for editmaps_db:
%
%    doc editmaps_db
%
% See also: editmaps
%
% Copyright (C) Kay Robbins and Thomas Rognon, UTSA, 2011-2013,
% krobbins@cs.utsa.edu
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
%
% $Log: editmaps_db.m,v $
% $Revision: 1.00 15-Feb-2013 08:03:48 krobbins $
% $Initial version $
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
end % editmaps_db