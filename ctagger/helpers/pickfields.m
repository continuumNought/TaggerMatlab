% pickfields
% Return the field names of fields user wishes to skip or exclude
%
% Usage:
%   >>  skipped = tagdir(fMap)
%   >>  [skipped, excluded] = pickfields(fMap)
%% Description
% [skipped, excluded] = pickfields(fMap) returns cell arrays of field
% names of the fields that the user wants to skip or exclude. Skipped
% fields are included in the final tags, but the user does not want to
% edit them with the ctagger GUI. Excluded fields are fields that the 
% user does not wish to include in the tagging at all. These field names
% are usually removed.

function excluded = pickfields(fMap, varargin)
    % Check the input arguments for validity
    parser = inputParser;
    parser.addRequired('fMap', @(x) (~isempty(x) && isa(x, 'fieldMap')));
    parser.addParamValue('SelectOption',  'select', ...
        @(x) any(validatestring(lower(x), {'none', 'select', 'type'})));
    parser.parse(fMap, varargin{:});
    selectOption = parser.Results.SelectOption;
    excluded = {};
    if strcmpi(selectOption, 'none')
        return;
    end
    
    fields = fMap.getFields();
    if strcmpi(selectOption, 'type')
       excluded = setdiff(fields, 'type');
       fields = intersect(fields, 'type');
    end
    if isempty(fields)
        return;
    end
    
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
            excluded = [excluded fields{k}]; %#ok<AGROW>
        elseif strcmpi(retValue, 'Cancel')
            excluded = {};
            return;
        end
    end   
end % pickfields