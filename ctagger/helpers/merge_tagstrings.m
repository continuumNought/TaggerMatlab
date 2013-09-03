% merge_tagstrings
% Returns a merged cell array of tags
%
% Input:
%    string1          first semicolon-separated string of tags
%    string2          second semicolon-separated string of tags
%    preservePrefix   If true all explicitly specified
%                     tags that are prefixes of other tags are retained. If
%                     false (the default), prefixes that are included as
%                     part of other tags are eliminated.
%
% Output:
%    mergedString = semicolon-separated string of tags or empty
%
% Notes:
%  - Tags are of a path-like form: /a/b/c
%  - Merging is case insensitive, but the result preserves the case
%    of the first tag encountered (i.e., list 1 over list 2).
%  - Tags that are prefixes of other tags are preserved by default
%  - Whitespace is trimmed from outside of tags
%
%
function mergedString = merge_tagstrings(string1, string2, preservePrefix)
mergedString = '';
if nargin < 3
    warning('merge_tagstrings:NotEnoughArguments', ...
        'function must have at 3 arguments');
    return;
end
parsed1 = regexpi(string1, ',', 'split');
parsed2 = regexpi(string2, ',', 'split');
merged = merge_taglists(parsed1, parsed2, preservePrefix);
if isempty(merged)
    return;
elseif ischar(merged)
    mergedString = strtrim(merged);
    return;
end

mergedString = strtrim(merged{1});
for k = 2:length(merged)
    mergedString = [mergedString ',' merged{k}]; %#ok<AGROW>
end
end % merge_tagstrings