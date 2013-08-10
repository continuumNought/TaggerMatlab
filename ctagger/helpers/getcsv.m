% getevents
% Create a fieldMap object for the existing tags in a data structure
%
% Usage:
%   >>  tMap = findtags(edata)
%   >>  tMap = findtags(edata, 'key1', 'value1', ...)
%
% Description:
% tMap = findtags(edata) extracts a fieldMap object representing the
% events and their tags for the structure.
%
% [keys, headers, descriptions] = getevents(file, 'key1', 'value1', ...) specifies optional name/value
% parameter pairs:
%
%   'ExcludeFields'  A cell array containing the field names to exclude
%   'Fields'         A cell array containing the field names to extract
%                    tags for.
%   'PreservePrefix' If false (default), tags of the same event type that
%                    share prefixes are combined and only the most specific
%                    is retained (e.g., /a/b/c and /a/b become just
%                    /a/b/c). If true, then all unique tags are retained.
%     parser.addRequired('FileName', @(x) (~isempty(x) && ischar(x)));
%     parser.addParamValue('Delimiter', '|', @(x) (ischar(x)));
%     parser.addParamValue('EventColumns', [], ...
%         @(x)(isnumeric(x) && (isscalar(x) || isvector(x))));
%     parser.addParamValue('DescriptionColumn', 0, ...
%         @(x)(isnumeric(x) && isscalar(x)));
% Notes:
%   The ddata structure should have its events encoded as a structure
%   array edata.events. The findtags will also examinate a edata.urevents
%   structure array if it exists. 
%
%   Tags are assumed to be stored in the edata.etc structure as follows:
%
%    edata.etc.tags.xml
%    edata.etc.tags.map
%       ...
%
% See also: tageeg, tagevents, and tagMap
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
% $Log: getevents.m,v $
% $Revision: 1.0 10-Aug-2013 08:13:44 krobbins $
% $Initial version $
%

function [keys, headers, descriptions] = getevents(filename, varargin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    parser = inputParser;
    parser.addRequired('FileName', @(x) (~isempty(x) && ischar(x)));
    parser.addParamValue('Delimiter', '|', @(x) (ischar(x)));
    parser.addParamValue('EventColumns', [], ...
        @(x)(isnumeric(x) && (isscalar(x) || isvector(x))));
    parser.addParamValue('DescriptionColumn', 0, ...
        @(x)(isnumeric(x) && isscalar(x)));
    parser.parse(filename, varargin{:});
    p = parser.Results;
    keys = {};
    headers = {};
    descriptions = {};
    values = linesplit(p.FileName);
    if isempty(values)
        return;
    end
    headers = values{1};
    keys = cell(length(values) - 1, 1);
    descriptions = cell(length(values) - 1, 1);
    for k = 2:length(values);
        [keys{k-1}, descriptions{k-1}] = makekey(values{k}, p.Delimiter);
    end
    for k = 1:length(headers)   
        fprintf('k=%d, header= %s\n', k, length(headers{k}));
    end
    for k = 1:length(keys)
        fprintf('k=%d, key= %s\n', k, keys{k});
    end
%     header = linesplit(fid);
%     if isempty(header)
%         return;
%     elseif isempty(p.EventColumns)
%         eColumns = 1:length(header);
%     end
%     keys
% 
% fclose(fid);

end

function values = linesplit(filename)
    values = {};
    fid = fopen(filename);
    lineNum = 0;
    tline = fgetl(fid);
    while ischar(tline)
        fprintf('tline=%s\n', tline);
        lineNum = lineNum + 1;
        values{lineNum} = strtrim(regexp(tline, ',', 'split')); %#ok<AGROW>
        tline = fgetl(fid);
    end
    fclose(fid);
end % linesplit  

function [key, description] = makekey(value, delimiter)
   key = value{1};
   description = '';
   for j = 2:length(value)
       key = [key delimiter value{j}]; %#ok<AGROW>
   end
end % makekey

