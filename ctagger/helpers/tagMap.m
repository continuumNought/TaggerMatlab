% tagMap    object encapsulating xml tags and value labels of one type
%
% Usage:
%   >>  eTags = tagMap(xmlString, values)
%   >>  eTags = tagMap(xmlString, values, 'key1', 'value1', ...)
%
% Description:
% eTags = tagMap(xmlString, values) creates an object representing the 
%    tag hierarchy for community tagging. The object knows how to merge and
%    can produce output in either JSON or semicolon separated
%    text format. The xmlString is an XML string with the tag hierarchy
%    and values is a structure array that holds the values and tags.
%
% eTags = tagMap(xmlString, values, 'key1', 'value1', ...)
%
%
% where the key-value pairs are:
%
%   'Field'            field name corresponding to these value tags
%   'PreservePrefix'   logical - if false (default) tags with matching
%                      prefixes are merged to be the longest
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
%             'RT,RT;flash,flash'
%
% Example 2: The unique value types in the EEG structure are the numerical
%            values: 1, 302, and 43. The output string is:
%
%            '1,1;302,302;43,43'
%
% After using the ctagger interface, it is recommended that users store
% the output in EEG.etc.tags field.
%
%
% eTagged =
%
%     field: 'type'
%     xml:    ''
%     values: [1x2 struct]
%
% The values field is either empty of contains a structure array:
% 
% Example:
%  1x2 struct array with fields:
%     label
%     description
%     tags
%
% Class documentation:
% Execute the following in the MATLAB command window to view the class
% documentation for tagMap:
%
%    doc tagMap
%
% See also: findtags, tageeg, tagdir, tagstudy, dataTags
%

%1234567890123456789012345678901234567890123456789012345678901234567890

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
%     properties (Constant = true)
%         DefaultXml = 'HEDSpecification1.3.xml';
%         DefaultSchema = 'HEDSchema.xsd';
%     end % constant
    
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
        
        function addValue(obj, value, updateType, preservePrefix)
            % Include value in this tagMap object based on updateType
            if ~tagMap.validateValue(value)
                warning('tagMap_addTags:invalid', ...
                    ['Could not add tags - value is not structure with' ...
                    ' label, description and tag fields']);
                return;
            elseif sum(strcmpi(updateType, ...
                    {'OnlyTags', 'Update', 'Replace', 'Merge', 'None'})) == 0
                warning('tagMap_addTags:invalidType', ...
                    ['updateType must be one of OnlyTags, Update, Replace, ' ...
                     'Merge, or None']);
                return;
            end
            
            % Does this value exist in this object?
            key = value.label;
            valueExists = obj.TagMap.isKey(key);
            if strcmpi(updateType, 'None') 
                return;
            elseif ~valueExists && ~strcmpi(updateType, 'Merge')
                return
            elseif ~valueExists || strcmpi(updateType, 'Replace')
                 obj.TagMap(key) = value;
                 return
            end
   
            % Merge tags of existing values
            oldValue = obj.TagMap(key);
            oldValue.tags = merge_taglists(oldValue.tags, ...
                value.tags, preservePrefix);
            if strcmpi(updateType, 'OnlyTags')
                obj.TagMap(key) = oldValue;
                return;
            end
            
            % Now handle merge or update of an existing value itself
            if isempty(oldValue.label)
                oldValue.code = value.label;
            end
            if isempty(oldValue.description)
                oldValue.description = value.description;
            end
            obj.TagMap(key) = oldValue;
        end % addValue
        
        function addValues(obj, values, updateType, preservePrefix)
            % Include event (a structure) in this tagMap object based on updateType
            for k = 1:length(values)
                obj.addValue(values(k), updateType, preservePrefix);
            end
        end % addValues
        
        function newMap = clone(obj)
            newMap = tagMap();
            newMap.Field = obj.Field;
            values = obj.TagMap.values;
            tMap = newMap.TagMap;
            for k = 1:length(values)
                tMap(values{k}.label) = values{k};
            end
            newMap.TagMap = tMap;
        end %clone        
        
        function value = getValue(obj, key)
            % Return the value structure corresponding to specified key
            if obj.TagMap.isKey(key)
                value = obj.TagMap(key);
            else
                value = '';
            end
        end % getValue
        
        function values = getValues(obj)
            % Return the values as a cell array of structures
            values = obj.TagMap.values;
        end % getValues
        
        function eStruct = getValueStruct(obj)
            % Return the values as a structure array
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
        end % getValues
 
        function field = getField(obj)
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
            % Return the unique value values of this type
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
           
        function merge(obj, eTags, updateType, preservePrefix)
            % Combine the eTags tagMap object info with this one
            if isempty(eTags)
                return;
            end
            field = eTags.getField();
            if ~strcmpi(field, obj.Field)
                return;
            end
            values = eTags.getValues();
            for k = 1:length(values)
                obj.addValue(values{k}, updateType, preservePrefix);
            end
        end % merge
              
        function setMap(obj, field, tMap)
            % Set the map associated with field to tMap
            obj.TagMap(field) = tMap;
        end % setMap
        
    end % public methods
    
    methods(Static = true)
        
        function value = createValue(elabel, edescription, etags)
            % Create structure for one value, output warning if invalid
            value = struct('label', num2str(elabel), ...
                'description', num2str(edescription), 'tags', '');
            value.tags = etags;
        end % createValue
        
        function eJson = value2Json(value)
            % Convert an value structure to a JSON string
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
        end
        
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
            % Convert an value structure array to a JSON string 
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
        end % json2mat
        
        function eStruct = json2Values(json)
            % Converts a JSON values string to a structure or empty string
            if isempty(json)
                eStruct = '';
            else
                eStruct = loadjson(json);
            end
        end % json2Values
        
        
        function [value, valid] = reformatValue(value)
            % Reformat and check value making sure empty tags are removed
            valid = tagMap.validateValue(value);
            if ~valid
                return;
            end
            value.label = strtrim(value.label);
            if isempty(value.label)
                valid = false;
                return
            end
            value.description = strtrim(value.description);
            if ~isfield(value, 'tags') || isempty(value.tags)
                value.tags = '';
            else
                tags = cellfun(@strtrim, cellstr(value.tags), 'UniformOutput', false);
                eCheck = cellfun(@isempty, tags);
                tags(eCheck) = [];
                if isempty(tags)
                    tags = '';
                elseif length(tags) == 1
                    tags = tags{1};
                end
                value.tags = tags;
            end
        end % reformatValue
        
        function [field, values] = split(inString, useJson)
            % Parse inString into xml hed string and values structure 
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

        function valid = validateValue(value)
            % Validate the structure array corresponding to value
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

