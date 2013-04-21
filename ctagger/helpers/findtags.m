% findtags
% Create an eventTags object for the existing tags in an EEG structure
%
% Usage:
%   >>  eTags = findtags(EEG)
%   >>  eTags = findtags(EEG, 'key1', 'value1', ...)
%
%% Description
% eTags = findtags(EEG) extracts an eventTags object representing the
% events and their tags for the EEG structure.
%
% eTags = findtags(EEG, 'key1', 'value1', ...)| specifies 
% optional name/value parameter pairs:
%   'Match'          A string with event matching criteria:
%                         'code' (default), 'label', or 'both'
%   'OnlyType'       If true (default), only tag based on unique event types
%                    and not on the other fields of EEG.event and
%                    EEG.urevent.
%   'PreservePrefix' If false (default), tags of the same event type that
%                    share prefixes are combined and only the most specific
%                    is retained (e.g., /a/b/c and /a/b become just
%                    /a/b/c). If true, then all unique tags are retained.
%
% See also: tageeg and eventTags
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

function eTags = findtags(EEG, varargin)
    % Parse the input arguments
    parser = inputParser;
    parser.addRequired('EEG', @(x) (isempty(x) || ...
        isstruct(EEG) || isfield(EEG, 'event') || ...
        isstruct(EEG.event) || isfield(EEG.event, 'type') || ...
        isfield(EEG, 'urevent') || isstruct(EEG.urevent) && ...
        isfield(EEG.urevent, 'type')));
    parser.addParamValue('Match', 'code', ...
        @(x) any(validatestring(lower(x), {'code', 'label', 'both'})));
    parser.addParamValue('OnlyType', true, ...
        @(x) validateattributes(x, {'logical'}, {}));
    parser.addParamValue('PreservePrefix', false, ...
        @(x) validateattributes(x, {'logical'}, {}));
    parser.parse(EEG, varargin{:});
    p = parser.Results;
    
    % Extract the existing events
    if ~isfield(EEG, 'etc')
        EEG.etc = struct('eventTags', '');
    elseif ~isstruct(EEG.etc)
        EEG.etc = struct('other', EEG.etc, 'eventTags', '');
    elseif ~isfield(EEG.etc, 'eventTags')
        EEG.etc.eventTags = '';
    end
    [hed, events] = eventTags.split(EEG.etc.eventTags, true);
    eTags = eventTags(hed, events, 'Match', p.Match, ...
                      'PreservePrefix', p.PreservePrefix);
    typesE =  unique(cellfun(@num2str, {EEG.event.type}, 'UniformOutput', false));
    typesURE =  unique(cellfun(@num2str, {EEG.urevent.type}, 'UniformOutput', false));
    types = union(typesE, typesURE);
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