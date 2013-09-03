% merge_taglists
% Returns a merged cell array of tags conforming to preservePrefix
%
% Input:
%    tList1        cellstr of tags or a single string or empty
%    tList2        cellstr of tags or a single string or empty
%    preservePrefix    ((optional) boolean. Ff true all explicitly specified
%                  tags that are prefixes of other tags are retained. If
%                  false (the default), prefixes that are included as
%                  part of other tags are eliminated.
%
% Output:
%    mergedList = cellstr of tags or a single tag or empty
%
% Notes:
%  - Tags are of a path-like form: /a/b/c
%  - Merging is case insensitive, but the result preserves the case
%    of the first tag encountered (i.e., list 1 over list 2).
%  - Tags that are prefixes of other tags are preserved by default
%  - Whitespace is trimmed from outside of tags
%
%
function mergedList = merge_taglists(tList1, tList2, preservePrefix)
mergedList = '';
if nargin < 3
    warning('merge_taglists:NotEnoughArguments', ...
        'function must e arguments');
    return;
end
myMap = containers.Map('KeyType', 'char', 'ValueType', 'any');

if ~isempty(tList1) && ischar(tList1)
    tList1 = {tList1};     % Convert string to cellstring
end
for k = 1:length(tList1)
    item = strtrim(tList1{k});
    itemKey = lower(item);  % Key is lower case
    if ~myMap.isKey(itemKey) && ~isempty(itemKey)
        myMap(itemKey) = item;
    end
end

if ~isempty(tList2) && ischar(tList2)
    tList2 = {tList2};     % Convert string to cellstring
end
for k = 1:length(tList2)
    item = strtrim(tList2{k});
    itemKey = lower(item);  % Key is lower case
    if ~myMap.isKey(itemKey) && ~isempty(itemKey)
        myMap(itemKey) = item;
    end
end
if ~preservePrefix
    myKeys = keys(myMap);
    myKeys = sort(myKeys);
    for k = 1:length(myKeys) - 1
        if ~isempty(regexp(myKeys{k+1}, ['^' myKeys{k}], 'match'))
            remove(myMap, myKeys{k});
        end
    end
end
mergedList = myMap.values();
if isempty(mergedList)
    mergedList = '';
elseif length(mergedList) == 1
    mergedList = mergedList{1};
end
end % merge_taglists