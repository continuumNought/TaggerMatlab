% tagMap    object encapsulating the tags and value labels of one type
%
% Usage:
%   >>  tMap = tagMap()
%   >>  tMap = tagMap('key1', 'value1', ...)
%
% Description:
% tMap = tagMap() creates an object that holds the associations of
% tags and values for one type or group name. By default the name
% of the field or type is 'type'.
%
% tMap = tagMap('key1', 'value1') where the key-value pair is:
%
%   'Field'            field name corresponding to these value tags
%
% Notes:
%
% Event string format:
%    Each unique value type is stored in comma separated form as
%    label,description, tags. The specifications for the individual
%    unique values types are separated by semicolumns. To form the
%    string for each value, the unique type is used as the code and
%    the name after num2str has been applied. The description
%    is empty.  The user will then use the
%
% Example 1: The unique value types in the EEG structure are 'RT' and
%            'flash'. The output string is:
%
%             'RT,RT description,;flash,flash description,'
%
% Example 2: The unique value types in the EEG structure are the numerical
%            values: 1, 302, and 43. The output string is:
%
%            '1,description 1,;302,description 302,;43,description 43,'
%
% Most of the arguments of tagMap a
%
% Example:
%  1x2 struct array with fields:
%     label
%     description
%     tags
%
% Description of update options for addValue:
%    'merge'         If the structure label is not a key of this map, add the
%                    entire structure as is, including the description.
%                    Otherwise, if the structure label is a
%                    key for this map, then merge the tags with those
%                    of the existing structure, using the PreservePrefix
%                    value to determine how to combine the tags.
%                    Also replace an empty description field with the
%                    description from the incoming structure.
%    'replace'       If the structure label is not a key of this map,
%                    do nothing. Otherwise, if the structure label is a
%                    key for this map, then completely replace the map
%                    value structure with this structure.
%    'onlytags'      If the structure label is not a key of this map,
%                    do nothing. Otherwise, if the structure label is a
%                    key for this map, then merge the tags with those
%                    of the existing structure, using the PreservePrefix
%                    value to determine how to combine the tags.
%    'update'        If the structure label is not a key of this map,
%                    do nothing. Otherwise, if the structure label is a
%                    key for this map, then merge the tags with those
%                    of the existing structure, using the PreservePrefix
%                    value to determine how to combine the tags.
%                    Also replace an empty description field with the
%                    description from the incoming structure.
%    'none'          Don't do any updating
%
% Class documentation:
% Execute the following in the MATLAB command window to view the class
% documentation for tagMap:
%
%    doc tagMap
%
% See also: findtags, tageeg, tagdir, tagstudy, dataTags
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
% $Log: tagMap.m,v $
% $Revision: 1.00 15-Feb-2013 08:03:48 krobbins $
% $Initial version $
%

classdef tagMap < hgsetget
    
    properties (Access = private)
        Field                % Name of field for this group of tags
        TagMap               % Map for matching value labels
    end % private properties
    
    methods
        function obj = tagMap(varargin)
            % Constructor parses parameters and sets up initial data
            parser = inputParser;
            parser.addParamValue('Field', 'type', ...
                @(x) (~isempty(x) && ischar(x)));
            parser.parse(varargin{:})
            obj.Field = parser.Results.Field;
            obj.TagMap = containers.Map('KeyType', 'char', 'ValueType', 'any');
        end % tagMap constructor
        
        function addValue(obj, value, varargin)
            % Add the value (structure) in this object based on updateType
            p = inputParser;
            p.addRequired('Value', @(x) (isempty(x) || ...
                tagMap.validateValue(value)));
            p.addParamValue('UpdateType', 'merge', ...
                @(x) any(validatestring(lower(x), ...
                {'OnlyTags', 'Update', 'Replace', 'Merge', 'None'})));
            p.addParamValue('PreservePrefix', false, ...
                @(x) validateattributes(x, {'logical'}, {}));
            p.parse(value, varargin{:});
            
            % Does this value exist in this object?
            key = value.label;
            updateType = p.Results.UpdateType;
            valueExists = obj.TagMap.isKey(key);
            preservePrefix = p.Results.PreservePrefix;
            if strcmpi(updateType, 'None') || (~valueExists && ...
                    (strcmpi(updateType, 'OnlyTags') || ...
                    strcmpi(updateType, 'Replace')))
                return;
            end
            
            % Handle Replace
            if strcmpi(updateType, 'Replace')
                value.tags = merge_taglists(value.tags, '', preservePrefix);
                obj.TagMap(key) = value;
                return;
            end
            
            % Handle OnlyTags and Merge
            if ~valueExists
                oldValue = value;
            else
                oldValue = obj.TagMap(key);
            end
            oldValue.tags = merge_taglists(oldValue.tags, ...
                value.tags, preservePrefix);
            if strcmpi(updateType, 'Merge') && isempty(oldValue.description)
                oldValue.description = value.description;
            end
            obj.TagMap(key) = oldValue;
        end % addValue
        
        function newMap = clone(obj)
            % Clone this tagMap object by making a copy of the map
            newMap = tagMap();
            newMap.Field = obj.Field;
            values = obj.TagMap.values;
            tMap = newMap.TagMap;
            for k = 1:length(values)
                tMap(values{k}.label) = values{k};
            end
            newMap.TagMap = tMap;
        end %clone
        
        function field = getField(obj)
            % Return the field name corresponding to this tagMap
            field = obj.Field;
        end % getField
        
        function jString = getJson(obj)
            % Return a JSON string version of the tagMap object
            jString = savejson('', obj.getStruct());
        end % getJson
        
        function jString = getJsonValues(obj)
            % Return a JSON string version of the tagMap object
            jString = tagMap.values2Json(obj.TagMap.values);
        end % getJson
        
        function eLabels = getLabels(obj)
            % Return the unique labels for this map
            eLabels = obj.TagMap.keys();
        end % getLabels
        
        function thisStruct = getStruct(obj)
            % Return this object in structure form
            thisStruct = struct('field', obj.Field, 'values', obj.getValueStruct());
        end % getStruct
        
        function thisText = getText(obj)
            % Return this object as semi-colon separated text
            thisText = [obj.Field ';'  obj.getTextValues()];
        end % getText
        
        function valuesText = getTextValues(obj)
            % Return values of this object as semi-colon separated text
            valuesText  = tagMap.values2Text(obj.TagMap.values);
        end % getTextValues
        
        function value = getValue(obj, label)
            % Return the value structure corresponding to specified label
            if obj.TagMap.isKey(label)
                value = obj.TagMap(label);
            else
                value = '';
            end
        end % getValue
        
        function values = getValues(obj)
            % Return the values of this tagMap as a cell array of structures
            values = obj.TagMap.values;
        end % getValues
        
        function eStruct = getValueStruct(obj)
            % Return the values of this tagMap as a structure array
            values = obj.TagMap.values;
            if isempty(values)
                eStruct = '';
            else
                nValues = length(values);
                eStruct(nValues) = values{nValues};
                for k = 1:nValues - 1
                    eStruct(k) = values{k};
                end
            end
        end % getValueStruct
        
        function merge(obj, mTags, updateType, preservePrefix)
            % Combine the mTags tagMap object info with this one
            if isempty(mTags)
                return;
            end
            field = mTags.getField();
            if ~strcmpi(field, obj.Field)
                return;
            end
            values = mTags.getValues();
            for k = 1:length(values)
                obj.addValue(values{k}, 'UpdateType', updateType, ...
                    'PreservePrefix', preservePrefix);
            end
        end % merge
        
    end % public methods
    
    methods(Static = true)
        
        function value = createValue(elabel, edescription, etags)
            % Create structure for one value
            value = struct('label', num2str(elabel), ...
                'description', num2str(edescription), 'tags', '');
            value.tags = etags;
        end % createValue
        
        function theStruct = json2Mat(json)
            % Convert a JSON object specification to a structure
            theStruct = struct('field', '', 'values', '');
            if isempty(json)
                return;
            end
            try
                theStruct = loadjson(json);
                % Adjust so tags are cellstrs
                for k = 1:length(theStruct.values)
                    if isempty(theStruct.values(k).tags)
                        continue;
                    end
                    theStruct.values(k).tags = ...
                        cellstr(theStruct.values(k).tags)';
                end
            catch ME
                if ~ischar(json)
                    warning('json2mat:InvalidJSON', ['not string' ME.message]);
                else
                    warning('json2mat:InvalidJSON', ...
                        ['json:[%s] ' ME.message], json);
                end
            end
        end % json2Mat
        
        function eStruct = json2Values(json)
            % Converts a JSON values string to a structure or empty string
            if isempty(json)
                eStruct = '';
            else
                eStruct = loadjson(json);
            end
        end % json2Values
        
        function [field, values] = split(inString, useJson)
            % Parse inString into a field and values structure
            field = '';
            values = '';
            if isempty(inString)
                return;
            elseif useJson
                theStruct = tagMap.json2Mat(inString);
            else
                theStruct = tagMap.text2Mat(inString);
            end
            field = theStruct.field;
            values = theStruct.values;
        end % split
        
        function eJson = value2Json(value)
            % Convert a value structure to a JSON string
            tags = value.tags;
            if isempty(tags)
                tagString = '';
            elseif ischar(tags)
                tagString = ['"' tags '"'];
            else
                tagString = ['"' tags{1} '"'];
                for j = 2:length(value.tags)
                    tagString = [tagString ',' '"' tags{j} '"']; %#ok<AGROW>
                end
            end
            tagString = ['[' tagString ']'];
            eJson = ['{"label":"' value.label ...
                '","description":"' value.description '","tags":' ...
                tagString '}'];
        end % value2Json
        
        function eText = value2Text(value)
            % Convert an value structure to comma-separated string
            tags = value.tags;
            if isempty(tags)
                tagString = '';
            elseif ischar(tags)
                tagString = tags;
            else
                tagString = tags{1};
                for j = 2:length(value.tags)
                    tagString = [tagString ',' tags{j}]; %#ok<AGROW>
                end
            end
            eText = [value.label ',' value.description ',' tagString];
        end % value2Text
        
        function eText = values2Json(values)
            % Convert a value structure array to a JSON string
            if isempty(values)
                eText = '';
            else
                eText = tagMap.value2Json(values{1});
                for k = 2:length(values)
                    eText = [eText ',' tagMap.value2Json(values{k})]; %#ok<AGROW>
                end
            end
            eText = ['[' eText ']'];
        end % values2Json
        
        function eText = values2Text(values)
            % Convert an value structure array or cell array to semi-colon separated string
            if isempty(values)
                eText = '';
            elseif isstruct(values)
                eText = tagMap.value2Text(values(1));
                for k = 2:length(values)
                    eText = [eText ';' tagMap.value2Text(values(k))]; %#ok<AGROW>
                end
            elseif iscell(values)
                eText = tagMap.value2Text(values{1});
                for k = 2:length(values)
                    eText = [eText ';' tagMap.value2Text(values{k})]; %#ok<AGROW>
                end
            end
        end % values2Text
        
        function theStruct = text2Mat(eString)
            % Convert semicolon-separated specification to struct
            theStruct = struct('field', '', 'values', '');
            eString = strtrim(eString);
            if isempty(eString)
                return;
            end
            [eStart, eParsed] = regexpi(eString, ';', 'start', 'split');
            if isempty(eParsed)
                return;
            end
            nEvents = length(eParsed);
            theStruct.field = strtrim(eParsed{1});
            if nEvents < 2
                return;
            end
            valueString = eString(eStart(1)+ 1:end);
            theStruct.values = tagMap.text2Values(valueString);
        end % text2mat
        
        function theStruct = text2Value(eString)
            % Parse a comma separated value string into its constituent pieces.
            theStruct = struct('label', '', 'description', '', 'tags', '');
            if isempty(eString)
                return;
            end
            splitEvent = regexpi(eString, ',', 'split');
            theStruct.label = splitEvent{1};
            if length(splitEvent) < 2
                return;
            end
            theStruct.description = splitEvent{2};
            if length(splitEvent) < 3
                return;
            end
            tags = strtrim(splitEvent(3:end));
            theStruct.tags = tags(~cellfun(@isempty, tags));
            if isempty(theStruct.tags)  %Clean up
                theStruct.tags = '';
            end
        end %text2Value
        
        function eStruct = text2Values(values)
            % Create an values structure array from a cell array of text values
            if length(values) < 1
                eStruct = '';
            else
                splitEvents = regexpi(values, ';', 'split');
                eStruct(length(splitEvents)) = ...
                    struct('label', '', 'description', '', 'tags', '');
                for k = 1:length(splitEvents)
                    eStruct(k)= tagMap.text2Value(splitEvents{k});
                end
            end
        end % text2Values
        
        function valid = validateValue(value)
            % Validate that the structure corresponds to a value
            if ~isstruct(value) || ...
                    sum(isfield(value, {'label', 'description', 'tags'})) ~= 3 || ...
                    ~ischar(value.label) || ...
                    (~isempty(value.description)&& ~ischar(value.description)) || ...
                    (~isempty(value.tags) && ...
                    ~iscellstr(value.tags) && ~ischar(value.tags))
                valid = false;
            else
                valid = true;
            end
        end % validateValue
        
    end % static method
end % tagMap

