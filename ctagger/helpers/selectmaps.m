% selectmaps
% Allows a user to select the fields to be used
%
% Usage:
%   >>  [fMap, excluded] = selectmaps(fMap)
%   >>  [fMap, excluded] = selectmaps(fMap, 'key1', 'value1', ...)
%
% Description
% [fMap, excluded] = selectmaps(fMap) removes the fields that are excluded
% by the user during selection.
%
% [fMap, excluded] = selectmaps(fMap, 'key1', 'value1', ...) specifies
% optional name/value parameter pairs:
%   'Fields'         Cell array of field names of the fields to include
%                    in the tagging. If this parameter is non-empty,
%                    only these fields are tagged.
%   'SelectOption'   If true (default), the user is presented with a GUI 
%                    that allows users to select which fields to tag.
%
% Function documentation:
% Execute the following in the MATLAB command window to view the function
% documentation for selectmaps:
%
%    doc selectmaps
%
% See also: pop_tageeg, pop_tagstudy, pop_tagdir, pop_tagcsv
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
% $Log: selectmaps.m,v $
% $Revision: 1.0 21-Apr-2013 09:25:25 krobbins $
% $Initial version $
%

function [fMap, excluded] = selectmaps(fMap, varargin)

    % Check the input arguments for validity and initialize
    parser = inputParser;
    parser.addRequired('fMap', @(x) (~isempty(x) && isa(x, 'fieldMap')));
    parser.addParamValue('Fields', {}, @(x) (iscellstr(x)));
    parser.addParamValue('SelectOption', true, @islogical);
    parser.parse(fMap, varargin{:});

    % Figure out the fields to be used
    fields = fMap.getFields();
    sfields = parser.Results.Fields;
    if ~isempty(sfields)
       excluded = setdiff(fields, sfields);
       fields = intersect(fields, sfields);
       for k = 1:length(excluded)
           fMap.removeMap(excluded{k});
       end
    else
        excluded = {};
    end
 
    if isempty(fields) || ~parser.Results.SelectOption
        return;
    end
    
    excludeUser = {};
    % Tag the values associated with field
    for k = 1:length(fields)
        tMap = fMap.getMap(fields{k});
        if isempty(tMap)
            labels = {' '};
        else
            labels = tMap.getLabels();
        end
        retValue = tagdlg(fields{k}, labels);
        if strcmpi(retValue, 'Exclude')
            excludeUser = [excludeUser fields{k}]; %#ok<AGROW>
        elseif strcmpi(retValue, 'Cancel')
            excludeUser = {};
            break;
        end
    end
    
    if isempty(excludeUser)
        return;
    end
    
    % Remove the excluded fields
    for k = 1:length(excludeUser)
        fMap.removeMap(excludeUser{k});
    end
    excluded = union(excluded, excludeUser);
end % selectmaps