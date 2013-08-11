% csvtags
% Create a tagMap object for the existing an event/tag map in a csv file.
%
% Usage:
%   >> [tMap, headers] = csvtags(filename)
%   >> [tMap, headers] = csvtags('key1', 'value1', ...)
%
% Description:
% tMap = csvtags(filename) assumes that all of the 
% columns of the comma-separated file represented by filename contain
% event codes that should be appended with separators '|' to form a 
% single event code. The tMap variable contains tagMap object with the
% event/tag map information. The headers is a cell string
% array containing the first row of the file, which is assume to contain
% headers. 
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
%                    csvtags assumes that all columns correspond to event
%                    codes.
%   'TagsColumn'     A non-negative integer specifying the column 
%                    that corresponds to the tags that are currently
%                    assigned to the event code combination of that
%                    row of the csv file.
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
% $Log: csvtags.m,v $
% $Revision: 1.0 10-Aug-2013 08:13:44 krobbins $
% $Initial version $
%

function [tMap, headers] = csvtags(filename, varargin)
    parser = inputParser;
    parser.addRequired('FileName', @(x) (~isempty(x) && ischar(x)));
    parser.addParamValue('Delimiter', '|', @(x) (ischar(x)));
    parser.addParamValue('DescriptionColumn', 0, ...
        @(x)(isnumeric(x) && (isscalar(x) || isempty(x))));
    parser.addParamValue('EventColumns', 0, ...
        @(x)(isnumeric(x) && (isscalar(x) || isvector(x))));
    parser.addParamValue('PreservePrefix', false, ...
        @(x) validateattributes(x, {'logical'}, {}));
    parser.addParamValue('TagsColumn', 0, ...
        @(x)(isnumeric(x) && (isscalar(x) || isempty(x))));
    parser.parse(filename, varargin{:});
    p = parser.Results;
    headers = {};
    values = linesplit(p.FileName);
    if isempty(values)
        return;
    end
    headers = values{1};
    if p.EventColumns == 0
        p.EventColumns = 1:length(headers);
    end
    type = getkey(headers, p.EventColumns, p.Delimiter);
    tMap = tagMap('Field', type);
    fprintf('length values = %d\n', length(values));
    for k = 2:length(values);
        v = struct('label', ...
                    getkey(values{k}, p.EventColumns, p.Delimiter), ...
                    'description', ...
                    getval(values{k}, p.DescriptionColumn), ...
                    'tags', getval(values{k}, p.TagsColumn));
        tMap.addValue(v, 'PreservePrefix', p.PreservePrefix);
        fprintf('%d: %s\n', k, v.label);
    end
    for k = 1:length(headers)   
        fprintf('k=%d, header= %s\n', k, headers{k});
    end
   
end %csvtags

function values = linesplit(filename)
    values = {};
    fid = fopen(filename);
    lineNum = 0;
    tline = fgetl(fid);
    while ischar(tline)   
        lineNum = lineNum + 1;
        fprintf('%d: tline=%s\n', lineNum, tline);
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

function val = getval(value, col)
   if col == 0
       val = '';
   else
       val = value{col};
   end
end % getdescript

