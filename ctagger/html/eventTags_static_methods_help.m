%% static methods of eventTags
% Methods for conversion and loading of events
%
%% Syntax
%     |eJson = eventTags.event2Json(event)|
%     |eText = eventTags.event2Text(event)|
%     |eText = eventTags.events2Json(events)|
%     |eText = eventTags.events2Text(events)|
%     |theStruct =  eventTags.json2Mat(json)|
%     |eStruct = eventTags.json2Events(json)|
%     |baseTags = eventTags.loadTagFile(tagsFile)|
%     |[event, valid] = eventTags.reformatEvent(event)|  
%     |successful = eventTags.saveTagFile(tagsFile, tagsObject)|
%     |[hedXML, events] = eventTags.split(inString, useJson)|
%     |theStruct = eventTags.text2Event(eString)|
%     |eStruct = eventTags.text2Events(events)|
%     |theStruct = eventTags.text2Mat(eString)|
%     |valid = eventTags.validateEvent(event)|
%     |eventTags.validateHed(hedSchema, hedString)|
%% Description
% |eJson = eventTags.event2Json(event)| converts an event structure 
% to a JSON string.
%
% |eText = eventTags.event2Text(event)| converts an event structure 
% to comma-separated string.
%
% |eText = eventTags.events2Json(events)| converts an event structure 
% array to a JSON string. 
%
% |eText = eventTags.events2Text(events)| converts an event structure 
% array to semi-colon separated string.
%
% |theStruct =  eventTags.json2Mat(json)| converts a JSON object 
% specification to a structure.
%
% |eStruct = eventTags.json2Events(json)| converts a JSON events 
% string to a structure or empty string.
%
% |baseTags = eventTags.loadTagFile(tagsFile)| loads an eventTags object 
% from tagsFile.
%
% |[event, valid] = eventTags.reformatEvent(event)| reformats and checks 
% event making sure empty tags are removed.
%
% |successful = eventTags.saveTagFile(tagsFile, tagsObject)| 
% saves the |tagsObject| variable in the |tagsFile| file and returns
% an indicator of whether the save was successful.
%
% |[hedXML, events] = eventTags.split(inString, useJson)| parses |inString|
% into the |hedXML| XML string containing the HED hierarchy and an 
% events structure containing events. If |useJson| is true, then |inString|
% is assumed to be a JSON string, otherwise it is assumed to be a semicolon
% separated string.
%  
% |theStruct = eventTags.text2Event(eString)| parses a comma separated 
% event string into its constituent pieces.
%
% |eStruct = eventTags.text2Events(events)| creates an events structure 
% array from a cell array of text events.
% 
% |theStruct = eventTags.text2Mat(eString)| converts semicolon-separated 
% specification to struct.
%  
% |valid = eventTags.validateEvent(event)| validates the structure array 
% corresponding to event.
%  
% |eventTags.validateHed(hedSchema, hedString)| validates the hedString
% as empty or valid according to the |hedSchema| xml schema and throws
% an exception if invalid. (This is so that error messages from the underlying
% xml parser will be propagated to the caller.)
%
%
% *Notes:*
% The |match| parameter determines whether two events match. There are
% three possible strategies:  
% 
% * |code| - (the default) events match if their codes match
% * |label| - events match if their labels match
% * |both| - events match if both their labels and codes match
%
%% Example 1

%% Class documentation
% Execute the following in the MATLAB command window to view the class 
% documentation for |cTagger|:
%
%    doc cTagger
%
%% See also these other methods of |eventTags|
% <tagEvents_help.html |tagEvents|>,
% <tagEvents_addEvent_help.html |addEvent|> 
%


%% 
% Copyright 2013 Kay A. Robbins, University of Texas at San Antonio