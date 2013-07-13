%% get method of eventTags
% Different ways of getting information from an eventTags object
%
%% Syntax
%     |event = getEvent(obj, key)|
%     |events = getEvents(obj)|
%     |eStruct = getEventStruct(obj)|
%     |hedXML = getHedXML(obj)|
%     |jString = getJson(obj)|
%     |jString = getJsonEvents(obj)|
%     |match = getMatch(obj)|
%     |pPrefix = getPreservePrefix(obj)|  
%     |thisStruct = getStruct(obj)|
%     |thisText = getText(obj)|
%     |eventsText = getTextEvents(obj)|
%
%% Description
% |event = getEvent(obj, key)| returns an event structure if key 
% corresponds to an existing event, otherwise the method returns an 
% empty string.
%
% |events = getEvents(obj)| returns a cell array of the event structures
% contained in this eventTags object.
%
% |eStruct = getEventStruct(obj)| returns a structure array of the 
% event structures contained in this eventTags object rather than a 
% cell array as |getEvents| does.
%
% |hedXML = getHedXML(obj)| returns a string containing the HED XML.
%
% |jString = getJson(obj)| returns this object as a JSON string.
%
% |jString = getJsonEvents(obj)| returns a string containing the JSON
% representation of the events in this eventTags object.
%
% |match = getMatch(obj)| returns a string containing the event 
% match strategy (code, label, or both). (See notes below.)
%
% |pPrefix = getPreservePrefix(obj)| returns a logical value containing the  
% PreservePrefix flag.  False (the default) means no tag prefix duplication. 
% For example, the tags |/Stimulus/Visua| and |/Stimulus/Visual/Circle| 
% share a common prefix. If |pPrefix| is true, both will appear. However,
% if |pPrefix| is false, |/Stimulus/Visual/Circle| is considered a
% specialization of |/Stimulus/Visua| and only it will appear.
%
% |thisStruct = getStruct(obj)| returns this object in structure form.
% 
% |thisText = getText(obj)| returns this object as semi-colon separated
% text.
%  
% |eventsText = getTextEvents(obj)| returns the events of this object
% as semi-colon separated text.
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