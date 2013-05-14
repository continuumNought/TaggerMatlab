% findtags
% Create a dataTags object for the existing tags in a data structure
%
% Usage:
%   >>  eTags = findtags(edata)
%   >>  eTags = findtags(edata, 'key1', 'value1', ...)
%
% Description:
% dTags = findtags(edata) extracts a dataTags object representing the
% events and their tags for the structure.
%
% eTags = findtags(edata, 'key1', 'value1', ...) specifies optional name/value
% parameter pairs:
%
%   'Fields'         A cell array containing the field names to extract
%                    tags for.
%   'PreservePrefix' If false (default), tags of the same event type that
%                    share prefixes are combined and only the most specific
%                    is retained (e.g., /a/b/c and /a/b become just
%                    /a/b/c). If true, then all unique tags are retained.
%
%
% Notes:
%   The edata structure should have its events encoded as a structure
%   array edata.events. The findtags will also examinate a edata.urevents
%   structure array if it exists. 
%
%   Tags are assumed to be stored in the edata.etc structure as follows:
%
%    edata.etc.tags.xml
%    edata.etc.tags.type
%       ...
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

function [dTags] = findtags(edata, varargin)
    % Parse the input arguments
    parser = inputParser;
    parser.addRequired('edata', @(x) (isempty(x) || ...
        (isstruct(edata) && isfield(edata, 'event') && isstruct(edata.event))));
    parser.addParamValue('Fields', {'type'}, @(x) (iscellstr(x)));
    parser.addParamValue('PreservePrefix', false, ...
        @(x) validateattributes(x, {'logical'}, {}));
    parser.parse(edata, varargin{:});
    p = parser.Results;    
  
    % If edata.etc.tags exists, then extract tag information
    xml = '';
    fields = {};
    if isfield(edata, 'etc') && isstruct(edata.etc) && ...
            isfield(edata.etc, 'tags') && isstruct(edata.etc.tags)
      if isfield(edata.etc.tags, 'xml')
           xml = edata.etc.tags.xml;
      end
      fields = fieldnames(edata.etc.tags);
    end
    dTags = dataTags(xml, 'PreservePrefix', p.PreservePrefix);
    for k = 1:length(fields)
          if strcmpi('xml', fields{k})
              continue;
          end;
         event = eventTags.json2Events(edata.etc.tags.(fields{k}));
         dTags.addEvent(fields{k}, event, 'Merge');
    end
 
    efields = fieldnames(edata.event);
    if isfield(edata, 'urevent') && isstruct(edata.urevent)
        efields = union(efields, fieldnames(edata.urevent)); 
    end
    efields = setdiff(efields, {'latency'; 'urevent'});
    for k = 1:length(efields)
        tValues = getutypes(edata.event, efields{k});
        if isfield(edata, 'urevent') 
            tValues = union(tValues, getutypes(edata.urevent, efields{k}));
        end
        events = eventTags.text2Events(tValues);
        dTags.addEvents(efields{k}, events, 'Merge');
    end
end %findtags