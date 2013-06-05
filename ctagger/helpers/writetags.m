% writetags
% Write tags to a structure from the field map information
%
% Usage:
%   >>  edata = writetags(edata, fMap)
%   >>  edata = writetags(edata, fMap, 'key1', 'value1', ...)
%
% Description:
% edata = writetags(edata, fMap) inserts the tags in the edata structure
% as specified by the fMap fieldMap object, both in summary form and
% individually.
%
% tMap = findtags(edata, 'key1', 'value1', ...) specifies optional name/value
% parameter pairs:
%
%   'ExcludeFields'  A cell array containing the field names to exclude
%   'Fields'         A cell array containing the field names to extract
%                    tags for.
%   'PreservePrefix' If false (default), tags of the same event type that
%                    share prefixes are combined and only the most specific
%                    is retained (e.g., /a/b/c and /a/b become just
%                    /a/b/c). If true, then all unique tags are retained.
%    'UpdateType'     Indicates how tags are merged with initial tags if the
%                    tagging information is to be rewritten to the EEG
%                    files. The options are: 'merge', 'replace', 
%                    'onlytags' (default), 'update' or 'none'.
%
% Notes:
%   The tags are written to the data files in two ways. In both cases
%   the dataset x is assumed to be a MATLAB structure: 
%   1) If the 'RewriteOption' is either 'Both' or 'Summary', the tags
%      are written to the dataset in the x.etc.tags field:
%            x.etc.tags.xml
%            x.etc.tags.map.field1
%            x.etc.tags.map.field2 ...
%      
%
%   2) If the 'RewriteOption' is either 'Both' or 'Individual', the tags
%      are also written to x.event.usertags based on the individual 
%      values of their events.
%
% See also: tageeg, tagevents, and tagMap
%

%1234567890123456789012345678901234567890123456789012345678901234567890

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
% $Log: writetags.m,v $
% $Revision: 1.0 21-Apr-2013 09:25:25 krobbins $
% $Initial version $
%

function edata = writetags(edata, fMap, varargin)
    % Parse the input arguments
    parser = inputParser;
    parser.addRequired('edata', @(x) (isempty(x) || isstruct(x)));
    parser.addRequired('fMap', @(x) (~isempty(x) && isa(x, 'fieldMap')));
    parser.addParamValue('ExcludeFields', {}, @(x) (iscellstr(x)));
    parser.addParamValue('PreservePrefix', false, @islogical);
    parser.addParamValue('RewriteOption', 'Both', ...
          @(x) any(validatestring(lower(x), ...
          {'Both', 'Individual', 'None', 'Summary'})));
    parser.parse(edata, fMap, varargin{:});

    % Prepare the structure
    if isfield(edata, 'etc') && ~isstruct(edata.etc)
        edata.etc.other = edata.etc;
    end
    
    edata.etc.tags = '';   % clear the tags
    edata.etc.tags = struct('xml', fMap.getXml(), 'map', '');
    
    % Prepare the values
    tFields = setdiff(fMap.getFields(), parser.Results.ExcludeFields);
    eFields = {};
    if isfield(edata, 'event') && isstruct(edata.event)
        eFields = intersect(fieldnames(edata.event), tFields);
    end
    urFields = {};
    if isfield(edata, 'urevent') && isstruct(edata.urevent)
        urFields = intersect(fieldnames(edata.urevent), tFields);
    end
    
    % Write the etc.tags.map fields
    fields = union(eFields, urFields);  
    for k = 1:length(fields)
        edata.etc.tags.map.(fields{k}) = ...
            fMap.getMap(fields{k}).getTextEvents();
    end
 
%     
%     % If edata.etc.tags exists, then extract tag information
%     xml = '';
%     tfields = {};
%     if isfield(edata, 'etc') && isstruct(edata.etc) && ...
%             isfield(edata.etc, 'tags') && isstruct(edata.etc.tags)
%       if isfield(edata.etc.tags, 'xml')
%            xml = edata.etc.tags.xml;
%       end
%       if isfield(edata.etc.tags, 'map') 
%          tfields = fieldnames(edata.etc.tags.map);
%       end
%     end
%     tMap = fieldMap(xml, 'PreservePrefix', p.PreservePrefix);
%     if ~isempty(p.Fields)
%         tfields = intersect(p.Fields, tfields);
%     end
%     for k = 1:length(tfields)
%         eString = edata.etc.tags.map.(tfields{k});
%         eStruct = tagMap.text2Events(eString);
%         tMap.addEvents(tfields{k}, eStruct, 'Merge');
%     end
%     
%     efields = '';
%     if isfield(edata, 'event') && isstruct(edata.urevent)
%        efields = fieldnames(edata.event);
%     end
%     if isfield(edata, 'urevent') && isstruct(edata.urevent)
%         efields = union(efields, fieldnames(edata.urevent)); 
%     end
%     efields = setdiff(efields, p.ExcludeFields);
%     if ~isempty(p.Fields)
%         efields = intersect(p.Fields, efields);
%     end
%     eventForm = struct('label', '', 'description', '', 'tags', '');
%     for k = 1:length(efields)
%         tValues = getutypes(edata.event, efields{k});
%         if isfield(edata, 'urevent') 
%             tValues = union(tValues, getutypes(edata.urevent, efields{k}));
%         end
%         if isempty(tValues)
%             continue
%         end
%         for j = 1:length(tValues)
%            eventForm.label = num2str(tValues{j});
%            tMap.addEvent(efields{k}, eventForm, 'Merge');
%         end
%     end
end %findtags