% fieldMap    object encapsulating xml tags and type-tagMap association
%
% Usage:
%   >>  dTags = fieldMap()
%   >>  dTags = fieldMap('key1', 'value1', ...)
%
% Description:
% dTags = fieldMap() creates an object representing the 
%    tag hierarchy for community tagging. The object knows how to merge and
%    can produce output in either JSON or semicolon separated
%    text format. The xmlString is an XML string with the tag hierarchy
%    and events is a structure array that holds the events and tags.
%
% dTags = fieldMap('key1', 'value1', ...) where the key-value pairs are:
%
%   'Description'      string describing the purpose of this field map.
%   'PreservePrefix'   logical - if false (default) tags with matching
%                      prefixes are merged to be the longest
%   'XML'              XML string specifying tag hierarchy to be used.
%
%
% addTags mergeOptions:
%    'Merge'          If an event with that key is not part of this
%                     object, add it as is. 
%
%    'NoUpdate'       Don't update anything in the structure
%
%    'Replace'        If an event with that key is not part of this
%                     object, do nothing. Otherwise, if an event with that
%                     key is part of this object then completely replace 
%                     that event with the new one.
%
%    'TagsOnly'       If an event with that key is not part of this
%                     object, do nothing. Otherwise, if an event with that
%                     key is part of this object, then update the tags of 
%                     the matching event with the new ones from this event,
%                     using the PreservePrefix value to determine how to
%                     combine the tags.
%
%    'Update'         If an event with that key is not part of this
%                     object, do nothing. Otherwise, if an event with that
%                     key is part of this object, then update the tags of 
%                     the matching event with the new ones from this event,
%                     using the PreservePrefix value to determine how to
%                     combine the tags. Also update any empty code, label
%                     or description fields by using the values in the
%                     input event.
%
% Notes:
%
% Event string format:
%    Each unique event type is stored in comma separated form as
%    label,description, tags. The specifications for the individual
%    unique events types are separated by semicolumns. To form the
%    string for each event, the unique type is used as the code and
%    the name after num2str has been applied. The description
%    is empty.  The user will then use the
%
% Example 1: The unique event types in the EEG structure are 'RT' and
%            'flash'. The output string is:
%
%             'RT,RT;flash,flash'
%
% Example 2: The unique event types in the EEG structure are the numerical
%            values: 1, 302, and 43. The output string is:
%
%            '1,1;302,302;43,43'
%
% Class documentation:
% Execute the following in the MATLAB command window to view the class
% documentation for tagMap:
%
%    doc tagMap
%
% See also: findtags, tageeg, tagdir, tagstudy, fieldMap
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

classdef fieldMap < hgsetget
    properties (Constant = true)
        DefaultXml = 'HEDSpecification1.3.xml';
        DefaultSchema = 'HEDSchema.xsd';
    end % constant
    
    properties (Access = private)
        Description          % String describing this field map
        PreservePrefix       % If true, don't eliminate duplicate prefixes (default false)
        GroupMap             % Map for matching event labels
        Xml                  % Tag hierarchy as an XML string
        XmlSchema            % String containing the XML schema
    end % private properties
    
    methods
        function obj = fieldMap(varargin)
            % Constructor parses parameters and sets up initial data
            parser = inputParser;
            parser.addParamValue('Description', '', ...
                @(x) (isempty(x) || ischar(x)));
            parser.addParamValue('PreservePrefix', false, ...
                @(x) validateattributes(x, {'logical'}, {}));
            parser.addParamValue('XML', '',@(x) (isempty(x) || ischar(x)));
            parser.parse(varargin{:})
            obj.Description = parser.Results.Description;
            obj.PreservePrefix = parser.Results.PreservePrefix;
            obj.Xml = fileread(fieldMap.DefaultXml);
            obj.XmlSchema = fileread(fieldMap.DefaultSchema);
            obj.mergeXml(parser.Results.XML);
            obj.GroupMap = containers.Map('KeyType', 'char', 'ValueType', 'any');
        end % fieldMap constructor       
        
        function addValues(obj, type, values, varargin)
            % Include event (a structure) in this tagMap object based on updateType
            p = inputParser;
            p.addRequired('Type', @(x) (~isempty(x) && ischar(x)));
            p.addRequired('Values', @(x) (isempty(x) || isstruct(x)));
            p.addParamValue('UpdateType', 'merge', ...
              @(x) any(validatestring(lower(x), ...
              {'OnlyTags', 'Update', 'Replace', 'Merge', 'None'})));
            p.parse(type, values, varargin{:});
            type = p.Results.Type;
            if ~obj.GroupMap.isKey(type)
                eTag = tagMap('Field', type);
            else
                eTag = obj.GroupMap(type);
            end

            for k = 1:length(values)
                eTag.addValue(values(k), ...
                    'UpdateType', p.Results.UpdateType, ...
                    'PreservePrefix', obj.PreservePrefix);
            end
            obj.GroupMap(type) = eTag;
        end % addValues
        
       function newMap = clone(obj)
            newMap = fieldMap();
            newMap.Description = obj.Description;
            newMap.PreservePrefix = obj.PreservePrefix;
            newMap.Xml = obj.Xml;
            newMap.XmlSchema = obj.XmlSchema;
            newMap.Xml = obj.Xml;
            values = obj.GroupMap.values;
            tMap = containers.Map('KeyType', 'char', 'ValueType', 'any');          
            for k = 1:length(values)
                tMap(values{k}.getField()) = values{k};
            end
            newMap.GroupMap = tMap;
        end %clone  
        
        function description = getDescription(obj)
            description = obj.Description;
        end % getDescription
        
        function fields = getFields(obj)
            fields = obj.GroupMap.keys();
        end % getFields
        
        function jString = getJson(obj)
            % Return a JSON string version of the tagMap object
            jString = savejson('', obj.getStruct());
        end % getJson
        
        function jString = getJsonEvents(obj)
            % Return a JSON string version of the tagMap object
            jString = tagMap.events2Json(obj.TagMap.values);
        end % getJson
        
        function tMap = getMap(obj, field)
            % Return the tagMap object associated with field or empty
            if ~obj.GroupMap.isKey(field)
                tMap = '';
            else
                tMap = obj.GroupMap(field);
            end
        end % getMap
        
        function tMaps = getMaps(obj)
            % Returns all of the tagMap objects as a cell array
            tMaps = obj.GroupMap.values;
        end % getMaps
        
        function pPrefix = getPreservePrefix(obj)
            % Return the PreservePrefix flag (false means no tag prefix duplication)
            pPrefix = obj.PreservePrefix;
        end % getPreservePrefix
        
        function thisStruct = getStruct(obj)
            % Return this object as a structure array
            thisStruct = struct('xml', obj.Xml, 'map', '');
            types = obj.GroupMap.keys();
            if isempty(types)
                return;
            end
            events = struct('field', types, 'events', '');
            for k = 1:length(types)
                eTags = obj.GroupMap(types{k});
                events(k).events = eTags.getValueStruct();
            end
            thisStruct.map = events;
        end % getStruct
        
        function tags = getTags(obj, field, event)
            % Returns tag string associated with value event of field
            tags = '';
            try
               tMap = obj.GroupMap(field);
               eStruct = tMap.getValue(event);
               tags = eStruct.tags;
            catch me %#ok<NASGU>
            end
        end % getTags
        
        function event = getValue(obj, type, key)
            % Return the event structure corresponding to specified key
            event = '';
            if obj.GroupMap.isKey(type)
                event = obj.GroupMap(type).getValue(key);
            end
        end % getValue
        
        function events = getValues(obj, type)
            % Return the events as a cell array of structures
            if obj.GroupMap.isKey(type)
               events = obj.GroupMap(type).getValues();
            else
                events = '';
            end;
        end % getValues
        
        function xml = getXml(obj)
            % Return a string containing the xml
            xml = obj.Xml;
        end % getXml
          
        function merge(obj, fMap, updateType, excludeFields)
            % Combine fMap fieldMap object with this, excluding certain fields
            if isempty(fMap)
                return;
            end
            obj.mergeXml(fMap.getXml);
            fields = fMap.getFields();
            fields = setdiff(fields, excludeFields);
            for k = 1:length(fields)
                type = fields{k};
                tMap = fMap.getMap(type);
                if ~obj.GroupMap.isKey(type)
                    obj.GroupMap(type) = tagMap('Field', type);
                end
                myMap = obj.GroupMap(type);
                myMap.merge(tMap, updateType, obj.PreservePrefix)
                obj.GroupMap(type) = myMap;
            end
        end % merge
        
        function mergeXml(obj, xmlMerge)
            % Merge the xml string with obj.HedXML if valid
            if isempty(xmlMerge)
                return;
            end
            try
               fieldMap.validateXml(obj.XmlSchema, xmlMerge);
            catch ex
                warning('fieldMap:mergeXml', ['Could not merge XML ' ...
                     ' [' ex.message ']']);
                return;
            end
            obj.Xml = char(edu.utsa.tagger.database.XMLGenerator.mergeXML( ...
                obj.Xml, xmlMerge));
        end % mergeXml
        
        function removeMap(obj, field)
            % Remove the fields specified by fieldSet from the fieldMap
            if ~isempty(field)
                obj.GroupMap.remove(field);
            end
        end % removeMap
        
        function setDescription(obj, description)
            obj.Description = description;
        end % setDescription
        
    end % public methods
      
    methods (Static = true)
        
        function baseTags = loadFieldMap(tagsFile)
            % Load a fieldMap object from tagsFile
            baseTags = '';
            try
                t = load(tagsFile);
                tFields = fieldnames(t);
                for k = 1:length(tFields);
                    nextField = t.(tFields{k});
                    if isa(nextField, 'fieldMap')
                        baseTags = nextField;
                        return;
                    end
                end
            catch ME         %#ok<NASGU>
            end
        end % loadFieldMap
        
        function successful = saveFieldMap(tagsFile, tagsObject) %#ok<INUSD>
            % Save the tagsObject variable in the tagsFile file
            successful = true;
            try
                eval([inputname(2) '= tagsObject;']);
                save(tagsFile, inputname(2));
            catch ME         %#ok<NASGU>
                successful = false;
            end
        end % saveTagFile
        
                function validateXml(schema, xmlString)
            % Validate xmlString as empty or valid XML (invalid throws exception) 
            if isempty(xmlString)
                return;
            end
            edu.utsa.tagger.database.XMLGenerator.validateSchemaString(...
                                 char(xmlString), char(schema));
        end % validateXml
        
    end % static methods
    
end %fieldMap

