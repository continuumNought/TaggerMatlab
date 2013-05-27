% fieldMap    object encapsulating xml tags and type-tagMap association
%
% Usage:
%   >>  dTags = fieldMap(xmlString)
%   >>  dTags = fieldMap(xmlString, 'key1', 'value1', ...)
%
% Description:
% dTags = fieldMap(xmlString) creates an object representing the 
%    tag hierarchy for community tagging. The object knows how to merge and
%    can produce output in either JSON or semicolon separated
%    text format. The xmlString is an XML string with the tag hierarchy
%    and events is a structure array that holds the events and tags.
%
% dTags = fieldMap(xmlString, 'key1', 'value1', ...)
%
%
% where the key-value pairs are:
%
%   'PreservePrefix'   logical - if false (default) tags with matching
%                      prefixes are merged to be the longest
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
% After using the ctagger interface, it is recommended that users store
% the output in EEG.etc.tags field.
%
%
% eTagged =
%
%     field: 'type'
%     hedXML: ''
%     events: [1x2 struct]
%
% The events field is either empty of contains a structure array:
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
        PreservePrefix       % If true, don't eliminate duplicate prefixes (default false)
        TypeMap              % Map for matching event labels
        Xml                  % Tag hierarchy as an XML string
        XmlSchema            % String containing the XML schema
    end % private properties
    
    methods
        function obj = fieldMap(xmlString, varargin)
            % Constructor parses parameters and sets up initial data
            if isempty(varargin)
                obj.parseParameters(xmlString);
            else
                obj.parseParameters(xmlString, varargin{:});
            end
        end % tagMap constructor
        
        function addEvent(obj, type, event, updateType)
            % Include event (a structure) in this tagMap object based on updateType
            % Does this type exist?
            if ~obj.TypeMap.isKey(type)
                eTag = tagMap(obj.Xml, '', 'Field', type);
            else
                eTag = obj.TypeMap(type);
            end

            % Add the event to the fieldMap
            eTag.addEvent(event, updateType);
            obj.TypeMap(type) = eTag;
        end % addEvent
        
        function addEvents(obj, type, events, updateType)
            % Include event (a structure) in this tagMap object based on updateType
            for k = 1:length(events)
                obj.addEvent(type, events(k), updateType);
            end
        end % addEvents
        
       function addTagMap(obj, eData, updateType)
            % Include information of the eData tagMap object based on updateType
            type = eData.getField();
            if ~obj.TypeMap.isKey(type)
                eTag = tagMap(obj.Xml, '', 'Field', type);
            else
                eTag = obj.TypeMap(type);
            end
            eTag.merge(eData, updateType);
        end % addTagMap
        
       function newMap = clone(obj)
            newMap = fieldMap(obj.Xml);
            newMap.PreservePrefix = obj.PreservePrefix;
            newMap.Xml = obj.Xml;
            newMap.XmlSchema = obj.XmlSchema;
            newMap.Xml = obj.Xml;
            values = obj.TypeMap.values;
            tMap = containers.Map('KeyType', 'char', 'ValueType', 'any');          
            for k = 1:length(values)
                tMap(values{k}.getField()) = values{k};
            end
            newMap.TypeMap = tMap;
        end %clone        
        
        function event = getEvent(obj, type, key)
            % Return the event structure corresponding to specified key
            event = '';
            if obj.TypeMap.isKey(type)
                event = obj.TypeMap(type).getEvent(key);
            end
        end % getEvent
        
        function events = getEvents(obj, type)
            % Return the events as a cell array of structures
            if obj.TypeMap.isKey(type)
                events = obj.TypeMap(type);
            else
                events = '';
            end;
        end % getEvents
        
        function tMap = getMap(obj, field)
            % Return the tagMap object associated with field or empty
            if ~obj.TypeMap.isKey(field)
                tMap = '';
            else
                tMap = obj.TypeMap(field);
            end
        end % getMap
        
        function tMaps = getMaps(obj)
            % Returns all of the tagMap objects as a cell array
            tMaps = obj.TypeMap.values;
        end % getMaps
        
        function fields = getFields(obj)
            fields = obj.TypeMap.keys();
        end % getFields
            
        function jString = getJson(obj)
            % Return a JSON string version of the tagMap object
            jString = savejson('', obj.getStruct());
        end % getJson
        
        function jString = getJsonEvents(obj)
            % Return a JSON string version of the tagMap object
            jString = tagMap.events2Json(obj.TagMap.values);
        end % getJson
        
        function pPrefix = getPreservePrefix(obj)
            % Return the PreservePrefix flag (false means no tag prefix duplication)
            pPrefix = obj.PreservePrefix;
        end % getPreservePrefix
        
        function thisStruct = getStruct(obj)
            % Return this object as a structure array
            thisStruct = struct('xml', obj.Xml, 'map', '');
            types = obj.TypeMap.keys();
            if isempty(types)
                return;
            end
            events = struct('field', types, 'events', '');
            for k = 1:length(types)
                eTags = obj.TypeMap(types{k});
                events(k).events = eTags.getEventStruct();
            end
            thisStruct.map = events;
        end % getStruct
        
%         function thisText = getText(obj)
%             % Return this object as semi-colon separated text
%             thisText = [obj.Field ';' obj.Xml ';' obj.getTextEvents()];
%         end % getText
%         
%         function eventsText = getTextEvents(obj)
%             % Return events of this object as semi-colon separated text
%             eventsText  = tagMap.events2Text(obj.TagMap.values);
%         end % getTextEvents

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
                if ~obj.TypeMap.isKey(type)
                    obj.TypeMap(type) = tagMap(obj.Xml, '', 'Field', type);
                end
                myMap = obj.TypeMap(type);
                myMap.merge(tMap, updateType)
                obj.TypeMap(type) = myMap;
            end
        end % merge
        
        function mergeXml(obj, xmlMerge)
            % Merge the xml string with obj.HedXML if valid
            if isempty(xmlMerge)
                return;
            end
            try
               tagMap.validateXml(obj.XmlSchema, xmlMerge);
            catch ex
                warning('tagMap:mergeXml', ['Could not merge XML ' ...
                     ' [' ex.message ']']);
                return;
            end
            obj.Xml = char(edu.utsa.tagger.database.XMLGenerator.mergeXML( ...
                obj.Xml, xmlMerge));
        end % mergeXml
        
        function removeMap(obj, fieldSet)
            % Remove the fields specified by fieldSet from the fieldMap
            if ~isempty(fieldSet)
                obj.TypeMap.remove(fieldSet);
            end
        end % removeMap
        
        function reset(obj, xmlString, eStruct)
            % Reset this object based on xmlString and event structure
            obj.TypeMap = containers.Map('KeyType', 'char', 'ValueType', 'any');
            obj.Xml = fileread(tagMap.DefaultXml);
            obj.XmlSchema = fileread(tagMap.DefaultSchema);
            obj.mergeXml(xmlString);
            for k = 1:length(eStruct)
                obj.addEvent(eStruct(k), 'Merge');
            end
        end % reset
        

        
        function setMap(obj, field, tMap)
            % Set the map associated with field to tMap
            obj.TagMap(field) = tMap;
        end % setMap
        
    end % public methods
    
    methods(Access = private)
        
        function xml = getXmlFile(xmlFile)
            % Merge the specified hedfile with the default
            xml = fileread(tagMap.DefaultXml);
            if nargin == 1 && ~isempty(xmlFile)
                xml = tagMap.mergeHed(xml, fileread(xmlFile));
            end
        end % getXml
        
        function parseParameters(obj, xmlString, varargin)
            % Parse parameters provided by user in constructor
            parser = fieldMap.getParser();
            parser.parse(xmlString, varargin{:})
            pdata = parser.Results;
            obj.PreservePrefix = pdata.PreservePrefix;
            obj.reset(pdata.XmlString, '')
        end % parseParameters
        
    end % private methods
    
    methods (Static = true)
       function parser = getParser()
            % Create a parser for blockedData
            parser = inputParser;
            parser.addRequired('XmlString', @(x) (isempty(x) || ischar(x)));
            parser.addParamValue('PreservePrefix', false, ...
                @(x) validateattributes(x, {'logical'}, {}));
        end % getParser
        
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
        
    end % static methods
    
end %fieldMap

