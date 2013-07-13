% selectmaps
% Allow user to selectively select the fields to be used
%
% Usage:
%   >>  [fMap, excluded] = selectmaps(fMap)
%   >>  [fMap, excluded] = selectmaps(fMap, 'key1', 'value1', ...)
%
% Description
% [fMap, excluded] = selectmaps(fMap) removes the fields that are excluded
% by the user during selection.
%
%
% [fMap, excluded] = selectmaps(fMap, 'key1', 'value1', ...) specifies
% optional name/value parameter pairs:
%   'Fields'         Cell array of field names of the fields to include
%                    in the tagging. If this parameter is non-empty,
%                    only these fields are tagged.
%   'SelectOption'   If true (default), the user is presented with a GUI 
%                    that allows users to select which fields to tag.
%
% ----STANDRAD DOcumentation --- here
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
end