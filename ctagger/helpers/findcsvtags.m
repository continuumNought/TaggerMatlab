% findcsvtags
% Creates an event structure for the existing an event/tag map in a csv file.
%
% Usage:
%   >> [events, type] = findcsvtags(filename)
%   >> [events, type] = findcsvtags(filename, 'key1', 'value1', ...)
%
% Description:
% [events, type] = findcsvtags(filename) assumes that all of the 
% columns of the comma-separated file represented by filename contain
% event codes that should be appended with separators '|' to form a 
% single event code. The events variable is a cell array of event 
% structures (i.e., structures with label, description, and tags fields). 
% The type is a string corresponding to the concatenation of the
% header columns corresponding to the event codes separated by the 
% delimiter.
%  
% [events, type] = getevents(file, 'key1', 'value1', ...) 
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
%   'TagsColumn'     A non-negative integer specifying the column 
%                    that corresponds to the tags that are currently
%                    assigned to the event code combination of that
%                    row of the csv file.
% See also: getevents and tagMap
%

% Copyright (C) Kay Robbins UTSA, 2011-2013, krobbins@cs.utsa.edu
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

function [events, type] = findcsvtags(filename, varargin)
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
    type = '';
    events = {};
    values = linesplit(p.FileName);
    if isempty(values)
       warning('findscvtags:invalidFile', ...
            ['Input file ' p.FileName ' does not exist or is invalid']);
        return;
    end
    headers = values{1};
    if p.EventColumns == 0
        p.EventColumns = 1:length(headers);
    end
    type = getkey(headers, p.EventColumns, p.Delimiter);
   
    fprintf('length values = %d\n', length(values));
    events = cell(length(values)-1, 1);
    for k = 2:length(values);
        events{k-1} = struct('label', ...
                    getkey(values{k}, p.EventColumns, p.Delimiter), ...
                    'description', ...
                    getval(values{k}, p.DescriptionColumn), ...
                    'tags', getval(values{k}, p.TagsColumn));
        fprintf('%d: %s\n', k, events{k-1}.label);
    end
    for k = 1:length(headers)   
        fprintf('k=%d, header= %s\n', k, headers{k});
    end
   
end %findcsvtags

function values = linesplit(filename)
    try 
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
    catch ME %#ok<NASGU>
        values = {};
    end    
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

