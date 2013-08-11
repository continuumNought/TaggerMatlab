% findcsvtags
% Create a fieldMap object for the existing tags in a data structure
%
% Usage:
%   >> fMap = findcsvtags(filename)
%   >> fMap = findcsvtags('key1', 'value1', ...)
%
% Description:
% fMap = findcsvtags(filename) assumes that all of the 
% columns of the comma-separated file represented by filename contain
% event codes that should be appended with separators '|' to form a 
% single event code. The codes variable contains a cell string array
% containing these consolidate event codes. The headers is a cell string
% array containing the first row of the file, which is assume to contain
% headers. The descriptions is a cell array of the same length as
% codes and contains empty strings.
%
% [codes, headers, descriptions] = getevents(file, 'key1', 'value1', ...) 
% specifies optional name/value parameter pairs:
%
%   'Delimiter'      A string containing the delimiter separating event
%                    code components. 
%   'DescriptionColumn'   A non-negative integer specifying the column 
%                    that corresponds to the event code description.
%                    Users should provide detailed documentation of
%                    exactly what this code means with respect to the
%                    particular experiment.
%   'EventColumns'   Either a non-negative integer or a vector of positive
%                    integers specifying the column(s) that correspond
%                    to event code components. If the value is 0, then
%                    findcsvtags assumes that all columns correspond to event
%                    codes.
% See also: getevents and tagMap
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
% $Log: findcsvtags.m,v $
% $Revision: 1.0 10-Aug-2013 08:13:44 krobbins $
% $Initial version $
%

function [codes, headers, descriptions] = findcsvtags(filename, varargin)
    parser = inputParser;
    parser.addRequired('FileName', @(x) (~isempty(x) && ischar(x)));
    parser.addParamValue('Delimiter', '|', @(x) (ischar(x)));
    parser.addParamValue('DescriptionColumn', 0, ...
        @(x)(isnumeric(x) && (isscalar(x) || isempty(x))));
    parser.addParamValue('EventColumns', 0, ...
        @(x)(isnumeric(x) && (isscalar(x) || isvector(x))));
    parser.parse(filename, varargin{:});
    p = parser.Results;
    codes = {};
    headers = {};
    descriptions = {};
    values = linesplit(p.FileName);
    if isempty(values)
        return;
    end
    headers = values{1};
    if p.EventColumns == 0
        p.EventColumns = 1:length(headers);
    end
    codes = cell(length(values) - 1, 1);
    descriptions = cell(length(values) - 1, 1);
    for k = 2:length(values);
        codes{k-1} = getkey(values{k}, p.EventColumns, p.Delimiter);
        descriptions{k-1} = getdescript(values{k}, p.DescriptionColumn);
    end
    for k = 1:length(headers)   
        fprintf('k=%d, header= %s\n', k, headers{k});
    end
    for k = 1:length(codes)
        fprintf('k=%d, key= %s\n', k, codes{k});
    end
end %findcsvtags

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

function key = getkey(value, cols, delimiter)
   v = value(cols);
   key = v{1};
   for j = 2:length(v)
       key = [key delimiter v{j}]; %#ok<AGROW>
   end
end % makekey

function description = getdescript(value, col)
   if col == 0
       description = '';
   else
       description = value{col};
   end
end % getdescript

