% csvMap
% Object encapsulating the csv representation of a tag map
%
% Usage:
%   >>  obj = csvMap(filename)
%   >>  obj = csvMap(filename, 'key1', 'value1', ...)
%
% Description:
% obj = csvMap(filename) creates an object that holds the associations of
% tags and values for one type or group name. By default the name
% of the field or type is 'type'.
%
% obj = csvMap(filename, 'key1', 'value1') where the key-value pair is:
%
%   'Delimiter'            Delimiter between tokens in the key
%   'DescriptionColumn'    Column number of description column
%   'EventColumns'         Numbers of the columns of event key labels
%   'TagsColumn'           Column number of tag column
%
% Class documentation:
% Execute the following in the MATLAB command window to view the class
% documentation for csvMap:
%
%    doc csvMap
%
% See also: findtags, tagcsv, tageeg, tagdir, tagstudy, dataTags
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
% $Log: csvMap.m,v $
% $Revision: 1.00 15-Feb-2013 08:03:48 krobbins $
% $Initial version $
%

classdef csvMap < hgsetget
    
    properties (Access = private)
        ColumnMap            % Hashmap of key versus row in Values
        DescriptionColumn    % Column number of description column
        Delimiter            % Delimiter between tokens in the key
        EventColumns         % Numbers of the columns of event key labels
        Header               % Cellstr of column names
        TagsColumn           % Column number of tag column
        Type                 % String repesentation of event key
        Values               % Cell array representation of csv file
    end % private properties
    
    methods
        function obj = csvMap(filename, varargin)
            % Constructor parses parameters and sets up initial data
            parser = inputParser;
            parser.addRequired('FileName', @(x) (~isempty(x) && ischar(x)));
            parser.addParamValue('Delimiter', '|', @(x) (ischar(x)));
            parser.addParamValue('DescriptionColumn', 0, ...
                @(x)(isnumeric(x) && (isscalar(x) || isempty(x))));
            parser.addParamValue('EventColumns', 0, ...
                @(x)(isnumeric(x) && (isscalar(x) || isvector(x))));
            parser.addParamValue('TagsColumn', 0, ...
                @(x)(isnumeric(x) && (isscalar(x) || isempty(x))));
            parser.parse(filename, varargin{:});
            p = parser.Results;
            obj.DescriptionColumn = p.DescriptionColumn;
            obj.Delimiter = p.Delimiter;
            obj.EventColumns = p.EventColumns;
            obj.TagsColumn = p.TagsColumn;
            obj.Values = splitcsv(p.FileName);
            if ~isempty(obj.Values) && isscalar(p.EventColumns) && ...
                    (p.EventColumns == 0)
                obj.EventColumns = 1:length(obj.Values{1});
            end
            obj.ColumnMap = containers.Map('KeyType', 'char', ...
                'ValueType','any');
            if isempty(obj.Values)
                obj.Header = {};
                obj.Type = '';
            else
                obj.Header = obj.Values{1};
                obj.Type = csvMap.getkey(obj.Header, ...
                    obj.EventColumns, obj.Delimiter);
                for k = 2:length(obj.Values)
                    obj.ColumnMap(csvMap.getkey(obj.Values{k}, ...
                        obj.EventColumns, obj.Delimiter)) = k;
                end
            end
        end % csvMap constructor
        
        function position = addEvent(obj, event)
            % Add event row to values and returns position or 0 not added
            if obj.ColumnMap.isKey(event.label)
                position = 0;
            else
                position = length(obj.Values) + 1;
                obj.ColumnMap(event.label) = position;
                row = cell(size(obj.Header));
                for k = 1:length(row)
                    row{k} = '';
                end
            end
        end % addEvent
        
        function events = getEvents(obj)
            % Return a structure array of event structures
            if isempty(obj.Values) || length(obj.Values) <= 1
                events = {};
                return;
            end
            events = cell(length(obj.Values)-1, 1);
            for k = 2:length(obj.Values);
                events{k-1} = struct('label', ...
                    csvMap.getkey(obj.Values{k}, obj.EventColumns, obj.Delimiter), ...
                    'description', csvMap.getval(obj.Values{k}, obj.DescriptionColumn), ...
                    'tags', csvMap.getval(obj.Values{k}, obj.TagsColumn));
            end
        end % getEvents
        
        function header = getHeader(obj)
            % Return a cellstr array with the tokens in first line of file
            header = obj.Header;
        end % getHeaders
        
        function eLabels = getLabels(obj)
            % Return the unique labels for this map
            eLabels = obj.ColumnMap.keys();
        end % getLabels
        
        function type = getType(obj)
            % Return a string containing the type names as a key
            type = obj.Type;
        end % getType
        
        function value = getValue(obj, label)
            % Return the value structure corresponding to specified label
            if obj.ColumnMap.isKey(label)
                value = obj.ColumnMap(label);
            else
                value = '';
            end
        end % getValue
        
        function values = getValues(obj)
            % Return the cell array of values from the original file
            values = obj.Values;
        end % getValues
        
        function values = updateDescriptionValues(obj, values, tMap)
            % Update the values cell array based on the description in
            % tag map tMap
            headerSize = length(obj.getHeader());
            tMapValues = cell2mat(tMap.getValues);
            descriptionValues = {tMapValues.description};
            descriptionColumn = obj.DescriptionColumn;
            existingColumn = true;
            if descriptionColumn == 0
                return;
            elseif descriptionColumn > headerSize
                header = values{1};
                header{descriptionColumn} = 'Description';
                values{1} = header;
                existingColumn = false;
            end
            for a = 2:length(values)
                currentValues = values{a};
                if ~isempty(descriptionValues{a-1})
                    currentValues{descriptionColumn} = ...
                        descriptionValues{a-1};
                elseif ~existingColumn
                    currentValues{descriptionColumn} = '';
                end
                values{a} = currentValues;
            end
        end % updateDescriptionValues
        
        function values = updateTagValues(obj, values, tMap)
            % Update the values cell array based on the tags in tag map
            % tMap
            rowKeys = obj.getRowKeys();
            headerSize = length(obj.getHeader());
            tagsColumn = obj.TagsColumn;
            if tagsColumn == 0
                header = values{1};
                header{end + 1} = 'Tags';
                tagsColumn = length(header);
                values{1} = header;
            elseif tagsColumn > headerSize
                header = values{1};
                header{tagsColumn} = 'Tags';
                values{1} = header;
            end
            for a = 2:length(values)
                value = tMap.getValue(rowKeys{a-1});
                currentValues = values{a};
                if isstruct(value)
                    if iscellstr(value.tags)
                        currentValues{tagsColumn} = ...
                            strjoin(value.tags, obj.Delimiter);
                    else
                        currentValues{tagsColumn} = value.tags;
                    end
                end
                values{a} = currentValues;
            end
        end % updateTagValues
        
        function writeTags(obj, tMap, filename)
            % Write the tags in csv format given a tag map tMap
            fid = fopen(filename,'w');
            values = obj.getValues();
            values = obj.updateTagValues(values, tMap);
            values = obj.updateDescriptionValues(values, tMap);
            numRows = length(values);
            for a = 1: numRows
                currentRow = values{a};
                numValues = length(currentRow);
                fprintf(fid, '%s', currentRow{1});
                for b = 2: numValues
                    fprintf(fid, ',%s', currentRow{b});
                end
                fprintf(fid, '\n');
            end
            fclose(fid);
        end % writetags
        
        function rowKeys = getRowKeys(obj)
            rowKeys = cell(length(obj.Values) - 1, 1);
            for k = 2:length(obj.Values)
                rowKeys{k-1} = csvMap.getkey(obj.Values{k}, ...
                    obj.EventColumns, obj.Delimiter);
            end            
        end % getRowKeys
        
    end % public methods
    
    
    methods(Static)
        
        function key = getkey(value, cols, delimiter)
            % Return a key given the column(s) of value
            v = value(cols);
            key = v{1};
            for j = 2:length(v)
                key = [key delimiter v{j}]; %#ok<AGROW>
            end
        end % getkey
        
        function val = getval(value, col)
            % Return the value of a particular column
            if col == 0 || col > length(value)
                val = '';
            else
                val = value{col};
            end
        end % getval
        
    end % static methods
    
end % csvMap

