% findtags
% Create a dataTags object for the existing tags in an EEG structure
%
% Usage:
%   >>  eTags = findtags(EEG)
%   >>  eTags = findtags(EEG, 'key1', 'value1', ...)
%
% Description:
% dTags = findtags(EEG) extracts a dataTags object representing the
% events and their tags for the EEG structure.
%
% eTags = findtags(EEG, 'key1', 'value1', ...) specifies optional name/value
% parameter pairs:
%
%   'Fields'         A cell array containing the field names to extract
%                    tags for.
%   'PreservePrefix' If false (default), tags of the same event type that
%                    share prefixes are combined and only the most specific
%                    is retained (e.g., /a/b/c and /a/b become just
%                    /a/b/c). If true, then all unique tags are retained.
%
% See also: tageeg, tagevents, and eventTags
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
% $Log: findtags.m,v $
% $Revision: 1.0 21-Apr-2013 09:25:25 krobbins $
% $Initial version $
%

function [eTags] = findtags(EEG, varargin)
    % Parse the input arguments
    parser = inputParser;
    parser.addRequired('EEG', @(x) (isempty(x) || ...
        (isstruct(EEG) && isfield(EEG, 'event') && isstruct(EEG.event) && ...
        isfield(EEG, 'urevent') && isstruct(EEG.urevent))));
    parser.addParamValue('Fields', {'type'}, @(x) (iscellstr(x)));
    parser.addParamValue('PreservePrefix', false, ...
        @(x) validateattributes(x, {'logical'}, {}));
    parser.parse(EEG, varargin{:});
    p = parser.Results;
    
    % Make sure EEG structure has .etc and .etc.tags fields
    if ~isfield(EEG, 'etc') || ~isfield(EEG.etc, 'tags')
        EEG.etc.tags = '';
    elseif ~isstruct(EEG.etc)
        EEG.etc = struct('other', EEG.etc, 'tags', '');
    end
    
    % Make sure EEG structure has .etc.tags.xml
    if ~isfield(EEG.etc.tags, 'xml')
        EEG.etc.tags.xml= '';
    end
    
    % Make sure EEG structure has .etc.tags.type fields
    for k = 1:length(p.Fields)
      if ~isfield(EEG.etc.tags, p.Fields{k})
        EEG.etc.tags.(p.Fields{k}) =  ''; 
      end
    end
    
    % Extract existing tags from the structure
    xml = EEG.etc.tags.xml;
    events = EEG.etc.tags.(p.FieldName);
    eTags = eventTags(xml, events, 'PreservePrefix', p.PreservePrefix);
      
    % Now find events 
    if ~isfield(EEG.event, p.FieldName)
        return;
    end
    try
       types =  unique(cellfun(@num2str, {EEG.event.(p.FieldName)}, ...
           'UniformOutput', false)); 
       if isfield(EEG, 'urevent')
          typesURE =  unique(cellfun(@num2str, {EEG.urevent.(p.FieldName)},...
            'UniformOutput', false));
          types = union(types, typesURE);
       end
    catch ME %#ok<NASGU>
        return;
    end
    if isempty(types)
        return;
    end

    % Add events that aren't tagged
    events = struct('code', types, 'label', types, ...
                    'description', '', 'tags', '');
    for k = 1:length(events)
        eTags.addEvent(events(k), 'Merge');
    end
end %findtags