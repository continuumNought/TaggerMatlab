% tagMap    object encapsulating xml tags and event labels of one type
%
% Usage:
%   >>  eTags = tagMap(xmlString, events)
%   >>  eTags = tagMap(xmlString, events, 'key1', 'value1', ...)
%
% Description:
% eTags = tagMap(xmlString, events) creates an object representing the 
%    tag hierarchy for community tagging. The object knows how to merge and
%    can produce output in either JSON or semicolon separated
%    text format. The xmlString is an XML string with the tag hierarchy
%    and events is a structure array that holds the events and tags.
%
% eTags = tagMap(xmlString, events, 'key1', 'value1', ...)
%
%
% where the key-value pairs are:
%
%   'Field'            field name corresponding to these event tags
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
%     xml:    ''
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
    properties (Constant = true)
        DefaultXml = 'HEDSpecification1.3.xml';
        DefaultSchema = 'HEDSchema.xsd';
    end % constant
    
    properties (Access = private)
        Field                % Name of field for this group of tags
        PreservePrefix       % If true, don't eliminate duplicate prefixes (default false)
        TagMap               % Map for matching event labels
        Xml                  % Tag hierarchy as an XML string
        XmlSchema            % String containing the XML schema
    end % private properties
    
    methods
        function obj = tagMap(xmlString, events, varargin)
            % Constructor parses parameters and sets up initial data
            if isempty(varargin)
                obj.parseParameters(xmlString, events);
            else
                obj.parseParameters(xmlString, events, varargin{:});
            end
        end % tagMap constructor
        
        function addEvent(obj, event, updateType)
            % Include event in this tagMap object based on updateType
            if ~tagMap.validateEvent(event)
                warning('tagMap_addTags:invalid', ...
                    ['Could not add tags - event is not structure with' ...
                    ' label, description and tag fields']);
                return;
            elseif sum(strcmpi(updateType, ...
                    {'OnlyTags', 'Update', 'Replace', 'Merge', 'None'})) == 0
                warning('tagMap_addTags:invalidType', ...
                    ['updateType must be one of OnlyTags, Update, Replace, ' ...
                     'Merge, or None']);
                return;
            end
            
            % Does this event exist in this object?
            key = event.label;
            eventExists = obj.TagMap.isKey(key);
            if strcmpi(updateType, 'None') 
                return;
            elseif ~eventExists && ~strcmpi(updateType, 'Merge')
                return
            elseif ~eventExists || strcmpi(updateType, 'Replace')
                 obj.TagMap(key) = event;
                 return
            end
   
            % Merge tags of existing events
            oldEvent = obj.TagMap(key);
            oldEvent.tags = merge_taglists(oldEvent.tags, ...
                event.tags, obj.PreservePrefix);
            if strcmpi(updateType, 'OnlyTags')
                obj.TagMap(key) = oldEvent;
                return;
            end
            
            % Now handle merge or update of an existing event itself
            if isempty(oldEvent.label)
                oldEvent.code = event.label;
            end
            if isempty(oldEvent.description)
                oldEvent.description = event.description;
            end
            obj.TagMap(key) = oldEvent;
        end % addEvent
        
        function newMap = clone(obj)
            newMap = tagMap(obj.Xml, '');
            newMap.Field = obj.Field;
            newMap.PreservePrefix = obj.PreservePrefix;
            newMap.Xml = obj.Xml;
            newMap.XmlSchema = obj.XmlSchema;
            values = obj.TagMap.values;
            tMap = containers.Map('KeyType', 'char', 'ValueType', 'any');          
            for k = 1:length(values)
                tMap(values{k}.label) = values{k};
            end
            newMap.TagMap = tMap;
        end %clone        
        
        function event = getEvent(obj, key)
            % Return the event structure corresponding to specified key
            if obj.TagMap.isKey(key)
                event = obj.TagMap(key);
            else
                event = '';
            end
        end % getEvent
        
        function events = getEvents(obj)
            % Return the events as a cell array of structures
            events = obj.TagMap.values;
        end % getEvents
        
        function eStruct = getEventStruct(obj)
            % Return the events as a structure array
            events = obj.TagMap.values;
            if isempty(events)
                eStruct = '';
            else
                nEvents = length(events);
                eStruct(nEvents) = events{nEvents};
                for k = 1:nEvents - 1
                    eStruct(k) = events{k};
                end
            end
        end % getEvents
 
        function field = getField(obj)
            field = obj.Field;
        end % getField

        function jString = getJson(obj)
            % Return a JSON string version of the tagMap object
            jString = savejson('', obj.getStruct());
        end % getJson
        
        function jString = getJsonEvents(obj)
            % Return a JSON string version of the tagMap object
            jString = tagMap.events2Json(obj.TagMap.values);
        end % getJson
        
               
        function eLabels = getLabels(obj)
            % Return the unique event values of this type
            eLabels = obj.TagMap.keys();
        end % getLabels
        
        function pPrefix = getPreservePrefix(obj)
            % Return the PreservePrefix flag (false means no tag prefix duplication)
            pPrefix = obj.PreservePrefix;
        end % getPreservePrefix
        
        function thisStruct = getStruct(obj)
            % Return this object in structure form
            thisStruct = struct('field', obj.Field, ...
                         'xml', obj.Xml, 'events', obj.getEventStruct());
        end % getStruct
        
        function thisText = getText(obj)
            % Return this object as semi-colon separated text
            thisText = [obj.Xml ';' obj.Field ';'  obj.getTextEvents()];
        end % getText
        
        function eventsText = getTextEvents(obj)
            % Return events of this object as semi-colon separated text
            eventsText  = tagMap.events2Text(obj.TagMap.values);
        end % getTextEvents
        
       function xml = getXml(obj)
            % Return a string containing the xml
            xml = obj.Xml;
        end % getXml
           
        function merge(obj, eTags, updateType)
            % Combine the eTags tagMap object info with this one
            if isempty(eTags)
                return;
            end
            obj.mergeXml(eTags.Xml);
            field = eTags.getField();
            if ~strcmpi(field, obj.Field)
                return;
            end
            events = eTags.getEvents();
            for k = 1:length(events)
                obj.addEvent(events{k}, updateType);
            end
        end % mergeEvents
        
        function mergeXml(obj, xmlMerge)
            % Merge the hedXML string with obj.HedXML if valid
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
        

        
        function reset(obj, xmlString, eStruct)
            % Reset this object based on hedString and event structure
            obj.TagMap = containers.Map('KeyType', 'char', 'ValueType', 'any');
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
        
        function parseParameters(obj, xmlString, events, varargin)
            % Parse parameters provided by user in constructor
            parser = tagMap.getParser();
            parser.parse(xmlString, events, varargin{:})
            pdata = parser.Results;
            obj.Field = pdata.Field;
            obj.PreservePrefix = pdata.PreservePrefix;
            obj.reset(pdata.XmlString, pdata.Events)
        end % parseParameters
        
    end % private methods
    
    methods(Static = true)
        
        function event = createEvent(elabel, edescription, etags)
            % Create structure for one event, output warning if invalid
            event = struct('label', num2str(elabel), ...
                'description', num2str(edescription), 'tags', '');
            event.tags = etags;
        end % createEvent
        
        function eJson = event2Json(event)
            % Convert an event structure to a JSON string
            tags = event.tags;
            if isempty(tags)
                tagString = '';
            elseif ischar(tags)
                tagString = ['"' tags '"'];
            else
                tagString = ['"' tags{1} '"'];
                for j = 2:length(event.tags)
                    tagString = [tagString ',' '"' tags{j} '"']; %#ok<AGROW>
                end
            end
            tagString = ['[' tagString ']'];
            eJson = ['{"label":"' event.label ...
                '","description":"' event.description '","tags":' ...
                tagString '}'];
        end
        
        function eText = event2Text(event)
            % Convert an event structure to comma-separated string
            tags = event.tags;
            if isempty(tags)
                tagString = '';
            elseif ischar(tags)
                tagString = tags;
            else
                tagString = tags{1};
                for j = 2:length(event.tags)
                    tagString = [tagString ',' tags{j}]; %#ok<AGROW>
                end
            end
            eText = [event.label ',' event.description ',' tagString];
        end % event2Text
        
        function eText = events2Json(events)
            % Convert an event structure array to a JSON string 
            if isempty(events)
                eText = '';
            else
                eText = tagMap.event2Json(events{1});
                for k = 2:length(events)
                    eText = [eText ',' tagMap.event2Json(events{k})]; %#ok<AGROW>
                end
            end
            eText = ['[' eText ']'];
        end % events2Json
        
        function eText = events2Text(events)
            % Convert an event structure array or cell array to semi-colon separated string
            if isempty(events)
                eText = '';
            elseif isstruct(events)
                eText = tagMap.event2Text(events(1));
                for k = 2:length(events)
                    eText = [eText ';' tagMap.event2Text(events(k))]; %#ok<AGROW>
                end
            elseif iscell(events)
                eText = tagMap.event2Text(events{1});
                for k = 2:length(events)
                    eText = [eText ';' tagMap.event2Text(events{k})]; %#ok<AGROW>
                end
            end
        end % events2Text
          
        function parser = getParser()
            % Create a parser for blockedData
            parser = inputParser;
            parser.addRequired('XmlString', ...
                @(x) (isempty(x) || ischar(x)));
            parser.addRequired('Events', ...
                @(x) (isempty(x) || (isstruct(x) && isfield(x, 'label') ...
                      && isfield(x, 'description') && isfield(x, 'tags'))))
            parser.addParamValue('Field', 'type', ...
                @(x) (~isempty(x) && ischar(x)));
            parser.addParamValue('PreservePrefix', false, ...
                @(x) validateattributes(x, {'logical'}, {}));
        end % getParser
        
        function theStruct = json2Mat(json)
            % Convert a JSON object specification to a structure
            theStruct = struct('field', '', 'xml', '', 'events', '');
            if isempty(json)
                return;
            end
            try
                theStruct = loadjson(json);
                % Adjust so tags are cellstrs
                for k = 1:length(theStruct.events)
                    if isempty(theStruct.events(k).tags)
                        continue;
                    end   
                    theStruct.events(k).tags = ...
                                      cellstr(theStruct.events(k).tags)';
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
        
        function eStruct = json2Events(json)
            % Converts a JSON events string to a structure or empty string
            if isempty(json)
                eStruct = '';
            else
                eStruct = loadjson(json);
            end
        end % json2Events
        
        
        function [event, valid] = reformatEvent(event)
            % Reformat and check event making sure empty tags are removed
            valid = tagMap.validateEvent(event);
            if ~valid
                return;
            end
            event.label = strtrim(event.label);
            if isempty(event.label)
                valid = false;
                return
            end
            event.description = strtrim(event.description);
            if ~isfield(event, 'tags') || isempty(event.tags)
                event.tags = '';
            else
                tags = cellfun(@strtrim, cellstr(event.tags), 'UniformOutput', false);
                eCheck = cellfun(@isempty, tags);
                tags(eCheck) = [];
                if isempty(tags)
                    tags = '';
                elseif length(tags) == 1
                    tags = tags{1};
                end
                event.tags = tags;
            end
        end % reformatEvent
        
 
        function [xml, field, events] = split(inString, useJson)
            % Parse inString into xml hed string and events structure 
            field = '';
            xml = '';
            events = '';
            if isempty(inString)
                return;
            elseif useJson
                theStruct = tagMap.json2Mat(inString);
            else
                theStruct = tagMap.text2Mat(inString);
            end
            field = theStruct.field;
            xml = theStruct.xml;
            events = theStruct.events;
        end % split
        
        function theStruct = text2Event(eString)
            % Parse a comma separated event string into its constituent pieces.
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
        end %text2Event
        
        function eStruct = text2Events(events)
            % Create an events structure array from a cell array of text events
            if length(events) < 1
                eStruct = '';
            else  
                splitEvents = regexpi(events, ';', 'split');
                eStruct(length(splitEvents)) = ...
                    struct('label', '', 'description', '', 'tags', '');
                for k = 1:length(splitEvents)
                    eStruct(k)= tagMap.text2Event(splitEvents{k});
                end
            end
        end % text2Events
        
        function theStruct = text2Mat(eString)
            % Convert semicolon-separated specification to struct 
            theStruct = struct('xml', '', 'field', '', 'events', '');
            eString = strtrim(eString);
            if isempty(eString)
                return;
            end
            [eStart, eParsed] = regexpi(eString, ';', 'start', 'split');
            if isempty(eParsed)
                return;
            end
            nEvents = length(eParsed);
            theStruct.xml = strtrim(eParsed{1});
            if nEvents < 2
                return;
            end
            theStruct.field = strtrim(eParsed{2});
            if nEvents < 3
                return;
            end
            eventString = eString(eStart(2)+ 1:end);
            theStruct.events = tagMap.text2Events(eventString);
        end % text2mat

        function valid = validateEvent(event)
            % Validate the structure array corresponding to event
            if ~isstruct(event)
                valid = false;
            elseif sum(isfield(event, {'label', 'description', 'tags'})) ~= 3
                valid = false;
            elseif ~ischar(event.label) || ~ischar(event.description)
                valid = false;
            elseif ~isempty(event.tags) && ...
                    ~iscellstr(event.tags) && ~ischar(event.tags)
                valid = false;
            else
                valid = true;
            end
        end % validateEvent
        
        function validateXml(schema, xmlString)
            % Validate xmlString as empty or valid XML (invalid throws exception) 
            if isempty(xmlString)
                return;
            end
            edu.utsa.tagger.database.XMLGenerator.validateSchemaString(...
                                 char(xmlString), char(schema));
        end % validateXml
        
    end % static method
end % tagMap

