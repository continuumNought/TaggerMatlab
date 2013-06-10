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
%   'PreservePrefix' If false (default), tags associated with same value that
%                    share prefixes are combined and only the most specific
%                    is retained (e.g., /a/b/c and /a/b become just
%                    /a/b/c). If true, then all unique tags are retained.
%   'RewriteOption'  String indicating how tag information should be
%                    written to the datasets. The options are 'Both',
%                    'Individual', 'None', 'Summary'. See the notes for
%                    additional information.
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
% See also: tageeg, fieldMap, and tagMap
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
    p = parser.Results;
    
    % Do nothing if option is 'none'
    if strcmpi(p.RewriteOption, 'None')
        return;
    end
    
    % Prepare the values to be written
    tFields = setdiff(fMap.getFields(), p.ExcludeFields);
    eFields = {};
    if isfield(edata, 'event') && isstruct(edata.event)
        eFields = intersect(fieldnames(edata.event), tFields);
    end
    urFields = {};
    if isfield(edata, 'urevent') && isstruct(edata.urevent)
        urFields = intersect(fieldnames(edata.urevent), tFields);
    end

    % Write the etc.tags.map fields
    eFields = intersect(union(eFields, urFields), tFields);
    
    % Write summary if needed (write all Fmap non-excluded fields
    if strcmpi(p.RewriteOption, 'Summary') || strcmpi(p.RewriteOption, 'Both')
       
        % Prepare the structure
        if isfield(edata, 'etc') && ~isstruct(edata.etc)
            edata.etc.other = edata.etc;
        end
        edata.etc.tags = '';   % clear the tags
        if isempty(tFields)
            map = '';
        else
            map(length(tFields)) = struct('field', '', 'values', '');  
            for k = 1:length(tFields)
                map(k).field = tFields{k};
                map(k).values = fMap.getMap(tFields{k}).getTextValues();
            end
        end
        edata.etc.tags = struct('xml', fMap.getXml(), 'map', map);
    end
    
    % Write tags to individual events in usertags field if needed
    if isfield(edata, 'event') && (strcmpi(p.RewriteOption, 'Both') ...
            || strcmpi(p.RewriteOption, 'Individual'))
        for k = 1:length(edata.event)
            utags = {};
            for j = 1:length(eFields)
                tags = fMap.getTags(eFields{j}, edata.event(k).(eFields{j}));
                utags = merge_taglists(utags, tags, p.PreservePrefix);
            end
            if isempty(utags)
                edata.event(k).usertags = '';
            elseif ischar(utags)
                edata.event(k).usertags = utags;
            else
                 tags = utags{1};
                 for j = 2:length(utags)
                     tags = [tags ',' utags{j}]; %#ok<AGROW>
                 end
                 edata.event(k).usertags = tags;
            end
        end
    end

end %writetags