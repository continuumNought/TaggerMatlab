% eventTags        encapsulates HED tags and events in a MATLAB object
%
% Usage:
%   >>  eTags = eventTags(hedString, events)
%   >>  eTags = eventTags(hedString, events, 'key1', 'value1', ...)
%
% Description:
% eTags = eventTags(hedString, events) creates an object representing the HED hierarchy
%    and tags for community tagging. The object knows how to merge and
%    can produce output in either JSON or semicolon separated
%    text format. The hedString is an XML string with the hed hierarchy
%    and events is a structure array that holds the events and tags.
%
% eTags = eventTags(hedString, events, 'key1', 'value1', ...)
%
%
% where the key-value pairs are:
%
%   'Match'            string with event matching criteria:
%                      'code' (default), 'label', or 'both'
%   'PreservePrefix'   logical - if false (default) tags with matching
%                      prefixes are merged to be the longest
%   'UseJson'          logical - if true (default) the inString is in
%                      Json format, otherwise in semicolon separated
%                      format.
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
%    code,name,description. The specifications for the individual
%    unique events types are separated by semicolumns. To form the
%    string for each event, the unique type is used as the code and
%    the name after num2str has been applied. The description
%    is empty.  The user will then use the
%
% Example 1: The unique event types in the EEG structure are 'RT' and
%            'flash'. The output string is:
%
%             'RT,RT,RT;flash,flash,flash'
%
% Example 2: The unique event types in the EEG structure are the numerical
%            values: 1, 302, and 43. The output string is:
%
%            '1,1,1;302,302,302;43,43,43'
%
% After using the ctagger interface, it is recommended that users store
% the output in EEG.etc.eventHedTags field.
%
%
% eTagged =
%
%     hedXML: ''
%     events: [1x2 struct]
%
% The events field is either empty of contains a structure array
% associating
% %events =
%
% 1x2 struct array with fields:
%     code
%     name
%     description
%     tags
%
% Class documentation:
% Execute the following in the MATLAB command window to view the class
% documentation for eventTags:
%
%    doc eventTags
%
% See also: cTagger
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
% $Log: eventTags.m,v $
% $Revision: 1.00 15-Feb-2013 08:03:48 krobbins $
% $Initial version $
%

classdef eventTags < hgsetget
    properties (Constant = true)
        DefaultHED = 'HEDSpecification1.3.xml';
        DefaultSchema = 'HEDSchema.xsd';
    end % constant
    
    properties (Access = private)
        HedSchema            % String containing the XML Hed schema
        HedXML               % HED hierarchy as an XML string
        Match                % String 'label', 'code', or 'both' (default 'code')
        PreservePrefix       % If true, don't eliminate duplicate prefixes (default false)
        TagMap               % Map for matching event codes
    end % private properties
    
    methods
        function obj = eventTags(hedString, events, varargin)
            % Constructor parses parameters and sets up initial data
            if isempty(varargin)
                obj.parseParameters(hedString, events);
            else
                obj.parseParameters(hedString, events, varargin{:});
            end
        end % eventTags constructor
        
        function eventExists = addEvent(obj, event, updateType)
            % Include event in this eventTags object based on updateType
            eventExists = false;
            if ~eventTags.validateEvent(event)
                warning('addTags:invalid', ...
                    ['Could not add tags - event is not structure with code,' ...
                    ' label, description and tag fields']);
                return;
            elseif sum(strcmpi(updateType, ...
                    {'TagsOnly', 'Update', 'Replace', 'Merge'})) == 0
                warning('addTags:invalidType', ...
                    ['updateType must be one of TagsOnly, Update, Replace, ' ...
                    ' or Merge']);
                return;
            end
            key = obj.getKey(event);
            if ~obj.TagMap.isKey(key) % Include a new event if Merge
                if strcmpi(updateType, 'Merge')
                    obj.TagMap(key) = event;
                end
                return;
            end
            eventExists = true;
            if strcmpi(updateType, 'Replace')
                obj.TagMap(key) = event;
                return;
            end
            oldEvent = obj.TagMap(key);
            oldEvent.tags = mergetaglists(oldEvent.tags, ...
                event.tags, obj.PreservePrefix);
            if strcmpi(updateType, 'TagsOnly')
                obj.TagMap(key) = oldEvent;
                return;
            end
            if isempty(oldEvent.code)
                oldEvent.code = event.code;
            end
            if isempty(oldEvent.label)
                oldEvent.code = event.label;
            end
            if isempty(oldEvent.description)
                oldEvent.description = event.description;
            end
            obj.TagMap(key) = oldEvent;
            eventExists = true;
        end % addEvent
        
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
            % Retrieve the events as a structure array
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
        
        function hedXML = getHedXML(obj)
            hedXML = obj.HedXML;
        end % getHedXML
        
        function jString = getJson(obj)
            % Return a JSON string version of the eventTags object
            jString = savejson('', obj.getStruct());
        end % getJson
        
        function jString = getJsonEvents(obj)
            % Return a JSON string version of the eventTags object
            jString = eventTags.events2Json(obj.TagMap.values);
        end % getJson
        
        function match = getMatch(obj)
            % Return the event match strategy (code, label, or both)
            match = obj.Match;
        end % getMatch
        
        function pPrefix = getPreservePrefix(obj)
            % Return the PreservePrefix flag (false means no duplication)
            pPrefix = obj.PreservePrefix;
        end % getPreservePrefix
        
        function eTags = getStruct(obj)
            % Return this object in structure form
            eTags = struct('hedXML', obj.HedXML, 'events', obj.getEventStruct());
        end % getStruct
        
        function tString = getText(obj)
            % Convert this object to semi-colon separated text
            tString = [obj.HedXML ';' obj.getTextEvents()];
        end % getText
        
        function tString = getTextEvents(obj)
            % Convert this eventTags object to semi-colon separated text
            tString = eventTags.events2Text(obj.TagMap.values);
        end % getTextEvents
        
        function mergeEventTags(obj, eTags, updateType)
            % Combine the eTags eventTags object info with this one
            if isempty(eTags)
                return;
            end
            obj.mergeHed(eTags.HedXML);
            events = eTags.getEvents();
            for k = 1:length(events)
                obj.addEvent(events{k}, updateType);
            end
        end % mergeEvents
        
        function mergeHed(obj, hedMerge)
            % Merge the hedXML string with obj.HedXML if valid
            if isempty(hedMerge)
                return;
            end
            try
               edu.utsa.tagger.database.XMLGenerator.validateSchemaString(...
                                           char(hedMerge), obj.HedSchema);
            catch ex
                warning('eventTags:mergeHed', ['Could not merge XML ' ...
                     ' [' ex.message ']']);
                return;
            end
            obj.HedXML = char(edu.utsa.tagger.database.XMLGenerator.mergeXML( ...
                obj.HedXML, hedMerge));
        end % mergeHED
        
        function reset(obj, hedString, eStruct)
            % Reset this object based on hedString and event structure
            obj.TagMap = containers.Map('KeyType', 'char', 'ValueType', 'any');
            obj.HedXML = fileread(eventTags.DefaultHED);
            obj.HedSchema = fileread(eventTags.DefaultSchema);
            obj.mergeHed(hedString);
            for k = 1:length(eStruct)
                obj.addEvent(eStruct(k), 'Merge');
            end
        end % reset
        
    end % public methods
    
    methods(Access = private)
        
        function hedXML = getHed(hedFile)
            % Merges the specified hedfile with the default
            hedXML = fileread(eventTags.DefaultHED);
            if nargin == 1 && ~isempty(hedFile)
                hedXML = eventTags.mergeHed(hedXML, fileread(hedFile));
            end
        end % getHed
        
       function key = getKey(obj, event)
            % Extract key from event structure
            if isempty(event)
                key = '';
            elseif strcmpi(obj.Match, 'code')
                key = event.code;
            elseif strcmpi(obj.Match, 'label')
                key = event.label;
            else
                key = [event.code '|$' event.label];
            end
        end % key
        
        function parseParameters(obj, hedString, events, varargin)
            % Parse parameters provided by user in constructor
            parser = eventTags.getParser();
            parser.parse(hedString, events, varargin{:})
            pdata = parser.Results;
            obj.Match = pdata.Match;
            obj.PreservePrefix = pdata.PreservePrefix;
            obj.reset(pdata.HedString, pdata.Events)
        end % parseParameters
        
 
    end % private methods
    
    methods(Static = true)
        
        function event = createEvent(ecode, elabel, edescription, etags)
            % Create structure for one event, output warning if invalid
            event = struct('code', num2str(ecode), 'label', num2str(elabel), ...
                'description', num2str(edescription), 'tags', '');
            event.tags = etags;
        end % createEvent
        
        function eJson = event2Json(event)
            % Create Json with correct format for Java Jackson parser
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
            eJson = ['{"code":"' event.code '","label":"' event.label ...
                '","description":"' event.description '","tags":' ...
                tagString '}'];
        end
        
        function eText = event2Text(event)
            % Return text version of a non empty event
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
            eText = [event.code ',' event.label ',' ...
                event.description ',' tagString];
        end % event2Text
        
        function eText = events2Json(events)
            % Return text version of a cell array of events
            if isempty(events)
                eText = '';
            else
                eText = eventTags.event2Json(events{1});
                for k = 2:length(events)
                    eText = [eText ',' eventTags.event2Json(events{k})]; %#ok<AGROW>
                end
            end
            eText = ['[' eText ']'];
        end % events2Json
        
        function eText = events2Text(events)
            % Return text version of a cell array of events
            if isempty(events)
                eText = '';
            else
                eText = eventTags.event2Text(events{1});
                for k = 2:length(events)
                    eText = [eText ';' eventTags.event2Text(events{k})]; %#ok<AGROW>
                end
            end
        end % events2Text
        

        
        function parser = getParser()
            % Create a parser for blockedData
            parser = inputParser;
            parser.addRequired('HedString', ...
                @(x) (isempty(x) || ischar(x)));
            parser.addRequired('Events', ...
                @(x) (isempty(x) || (isstruct(x) && isfield(x, 'code') ...
                     && isfield(x, 'label') && isfield(x, 'description') ...
                     && isfield(x, 'tags'))))
            parser.addParamValue('Match', 'code', ...
                @(x) (~isempty(x) && ischar(x) && ...
                sum(strcmpi(x, {'code', 'label', 'both'})) == 1));
            parser.addParamValue('PreservePrefix', false, ...
                @(x) validateattributes(x, {'logical'}, {}));
        end % getParser
        
        function theStruct = json2Mat(json)
            % Converts a JSON specification to a structure
            theStruct = struct('hedXML', '', 'events', '');
            if isempty(json)
                return;
            end
            try
                theStruct = loadjson(json);
            catch ME
                if ~ischar(json)
                    warning('json2mat:InvalidJSON', ['not string' ME.message]);
                else
                    warning('json2mat:InvalidJSON', ...
                        ['json:[%s] ' ME.message], json);
                end
            end
%            [theStruct, valid] = eventTags.reformatStruct(theStruct);
        end % json2mat
        
        function theStruct = json2Events(json)
            if isempty(json)
                theStruct = '';
            else
                theStruct = loadjson(json);
            end
        end % json2Events
        
        function [event, valid] = reformatEvent(event)
            % Reformat and check event making sure empty tags are removed
            valid = eventTags.validateEvent(event);
            if ~valid
                return;
            end
            event.code = strtrim(event.code);
            event.label = strtrim(event.label);
            if isempty(event.code) || isempty(event.label)
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
        
%         function [eStruct, valid] = reformatStruct(eStruct)
%             % Reformat the struct, detecting whether or not valid
%             if ~isstruct(eStruct) || ...
%                     sum(isfield(eStruct, {'hedXML', 'events'})) ~= 2 || ...
%                     ~ischar(eStruct.hedXML) || ...
%                     (~isempty(eStruct.events) && ~isstruct(eStruct.events))
%                 valid = false;
%                 return;
%             end
%             valid = eventTags.validateHed(eStruct.hedXML);
%             if ~valid
%                 return;
%             end
%             events = eStruct.events;
%             for k = 1:length(events)
%                 [events(k), valid] = eventTags.reformatEvent(events(k));
%                 if ~valid
%                     return;
%                 end
%             end
%             eStruct.events = events;
%         end % validateStruct

        function baseTags = loadTagFile(tagsFile)
            % Set baseTags if tagsFile contains an eventTags object
            baseTags = '';
            try
                t = load(tagsFile);
                tFields = fieldnames(t);
                for k = 1:length(tFields);
                    nextField = t.(tFields{k});
                    if isa(nextField, 'eventTags')
                        baseTags = nextField;
                        return;
                    end
                end
            catch ME         %#ok<NASGU>
            end
        end % loadTagFile
        
        function successful = saveTagFile(tagsFile, tagsObject) %#ok<INUSD>
            % Set baseTags if tagsFile contains an eventTags object
            successful = true;
            try
                save(tagsFile, inputname(2));
            catch ME         %#ok<NASGU>
                successful = false;
            end
        end % saveTagFile
        
        function [hedXML, events] = split(inString, useJson)
            % Return the hedString and the events structure
            hedXML = '';
            events = '';
            if isempty(inString)
                return;
            elseif useJson
                theStruct = eventTags.json2Mat(inString);
            else
                theStruct = eventTags.text2Mat(inString);
            end
            
            hedXML = theStruct.hedXML;
            events = theStruct.events;
        end % split
        
        function theStruct = text2Event(eString)
            %Parse a comma separated event string into its constituent pieces.
            theStruct = struct('code', '', 'label', '', 'description', '', ...
                'tags', '');
            if isempty(eString)
                return;
            end
            splitEvent = regexpi(eString, ',', 'split');
            theStruct.code = splitEvent{1};
            if length(splitEvent) < 2
                return;
            end
            theStruct.label = splitEvent{2};
            if length(splitEvent) < 3
                return;
            end
            theStruct.description = splitEvent{3};
            if length(splitEvent) < 4
                return;
            end
            theStruct.tags = splitEvent(4:end);
        end %text2Event
        
        function eStruct = text2Events(events)
            % Return an events structure from a cell array of text events
            if length(events) < 1
                eStruct = '';
            else  
                for k = length(events):-1: 1
                    eStruct(k)= eventTags.text2Event(events{k});
                end
            end
        end % text2Events
        
        function theStruct = text2Mat(eString)
            % Convert semicolon-separated specification to struct 
            theStruct = struct('hedXML', '', 'events', '');
            eString = strtrim(eString);
            if isempty(eString)
                return;
            end
            eParsed = regexpi(eString, ';', 'split');
            theStruct.hedXML = eParsed{1};
            theStruct.events = eventTags.text2Events(eParsed(2:end));
        end % text2mat

        function valid = validateEvent(event)
            % validate the structure array corresponding to event
            if ~isstruct(event)
                valid = false;
            elseif sum(isfield(event, ...
                    {'code', 'label', 'description', 'tags'})) ~= 4
                valid = false;
            elseif ~ischar(event.code) || ~ischar(event.label) || ...
                    ~ischar(event.description)
                valid = false;
            elseif ~isempty(event.tags) && ...
                    ~iscellstr(event.tags) && ~ischar(event.tags)
                valid = false;
            else
                valid = true;
            end
        end % validateEvent
        

        
%         function valid = validateHed(hedString, hedSchema)
%             % Validate hedString as empty or valid XML 
%             valid = true;
%             if isempty(hedString)
%                 return;
%             end
%             edu.utsa.tagger.database.XMLGenerator.validateSchemaString(...
%                                                    hedString, hedSchema);
%         end % validHED
%         
    end % static method
end % eventTags

