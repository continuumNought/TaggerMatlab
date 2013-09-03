% getutypes
% Returns a cell array with the unique values in the type field of estruct
%
function tValues = getutypes(estruct, type)
tValues = {};
% Not a field so no values
if ~isstruct(estruct) || ~isfield(estruct, type)
    return;
end
try
    values = {estruct.(type)};
    isNum = cell2mat(cellfun(@isnumeric, values, 'UniformOutput', false));
    tValues = unique(cellfun(@num2str, values, 'UniformOutput', false));
    if sum(isNum) > 0 && sum(~cellfun(@isempty, strfind(tValues, '.'))) > 0
        tValues = {};
        return;
    end
    tEmpty = cellfun(@isempty, tValues);
    tValues(tEmpty) = [];
    tNaN = strcmpi('NaN', tValues);
    tValues(tNaN) = [];
catch ME %#ok<NASGU>
end
end % getutypes

