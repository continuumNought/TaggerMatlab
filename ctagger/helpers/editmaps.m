% editmaps
% Allows a user to selectively edit the tags using the ctagger GUI
%
% Usage:
%   >>  fMap = editmaps(fMap)
%   >>  fMap = editmaps(fMap, 'key1', 'value1', ...)
%
% Description:
% fMap = editmaps(fMap) presents a CTAGGER tagging GUI for each of the
% fields in fMap and allows users to tag, add items to the tag
% hierarchy or add/edit events.
%
% fMap = editmaps(fMap, 'key1', 'value1', ...) specifies
% optional name/value parameter pairs:
%
%   'PreservePrefix' If false (default), tags of the same event type that
%                    share prefixes are combined and only the most specific
%                    is retained (e.g., /a/b/c and /a/b become just
%                    /a/b/c). If true, then all unique tags are retained.
%   'Synchronize'    If false (default), the ctagger GUI is run with
%                    synchronization done using the MATLAB pause. If
%                    true, synchronization is done within Java. This
%                    latter option is usually reserved when not calling
%                    the GUI from MATLAB.
%
% Function documentation:
% Execute the following in the MATLAB command window to view the function
% documentation for editmaps:
%
%    doc editmaps
%
% See also: editmaps_db
%
% Copyright (C) Kay Robbins and Thomas Rognon, UTSA, 2011-2013, krobbins@cs.utsa.edu
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
% $Log: editmaps.m,v $
% $Revision: 1.00 15-Feb-2013 08:03:48 krobbins $
% $Initial version $
%

function fMap = editmaps(fMap, varargin)
% Check the input arguments for validity and initialize
parser = inputParser;
parser.addRequired('fMap', @(x) (~isempty(x) && isa(x, 'fieldMap')));
parser.addParamValue('PreservePrefix', false, @islogical);
parser.addParamValue('Synchronize', true, @islogical);
parser.parse(fMap, varargin{:});
syncThis = parser.Results.Synchronize;

fields = fMap.getFields();
for k = 1:length(fields)
    fprintf('Tagging %s\n', fields{k});
    editmap(fields{k});
end

    function editmap(field)
        % Proceed with tagging for field values and adjust fMap accordingly
        tMap = fMap.getMap(field);
        if isempty(tMap)
            return;
        end
        tValues = strtrim(char(tMap.getJsonValues()));
        xml = fMap.getXml();
        eTitle = ['Tagging ' field ' values'];
        if syncThis
            %             taggedList = edu.utsa.tagger.Controller.showDialog( ...
            %                 xml, tValues, true, 0, char(eTitle), 3);
            taggedList = edu.utsa.tagger.Loader.load(xml, tValues, true, 0, eTitle, 3);
            xml = char(taggedList(1, :));
            tValues = strtrim(char(taggedList(2, :)));
        else
            %             javaMethodEDT('createController', ...
            %                 'edu.utsa.tagger.Controller', xml, tValues, true, 0, ...
            %                 eTitle, 3);
            loader = ...
                edu.utsa.tagger.Loader(xml, tValues, true, 0, eTitle, 3);
            %             notified = edu.utsa.tagger.Controller.get().getNotified();
            notified = loader.isNotified();
            while (~notified)
                pause(0.5);
                %                 notified = edu.utsa.tagger.Controller.get().getNotified();
                notified = loader.isNotified();
            end
            %             taggedList = edu.utsa.tagger.Controller.getReturnString(true);
            taggedList = edu.utsa.tagger.Loader.load(xml, tValues, true, 0, eTitle, 3);
            if ~isempty(taggedList)
                xml = char(taggedList(1, :));
                tValues = strtrim(char(taggedList(2, :)));
            end
        end
        tValues = tagMap.json2Values(tValues);
        fMap.mergeXml(strtrim(xml));
        fMap.removeMap(field);
        fMap.addValues(field, tValues);
    end % editmap

end % editmaps