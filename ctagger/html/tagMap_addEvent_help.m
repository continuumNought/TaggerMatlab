%% get method of eventTags
% Different ways of getting information from an eventTags object
%
%% Syntax
%     |event = getEvent(obj, key)|
%
%% Description
% |eventExists = addEvent(obj, event, updateType)| adds an event, as specified
% by an |event| structure to the |obj| eventTags object. The method call
% returns a flag indicating whether the event already exists or not.
%
% The |event| argument is a structure with |code|, |label|, |description|
% and |tags| fields. The first three fields contain empty or string values,
% while the |tags| field can be empty, a string or a cell array of strings.
%
% An example of the structure is:
%          label: 'RT'
%    description: 'RT'
%           tags: {'/Time-Locked Event/Stimulus/Visual/Shape/Ellipse/Circle' [1x54 char]}
%
% 
% The |updateType| can be one of the following values:
%
% <html>
% <table>
% <thead><tr><td>Name</td><td>Description of action</td></tr></thead>
% <tr><td><tt>'OnlyTags'</tt></td>
%      <td>If the new event matches an existing event, merge the
%          the tags. If the new event does not match, do nothing.</td></tr>
% <tr><td><tt>'Update'</tt></td>
%      <td>If the new event matches the existing event, update the
%          tags and propagate any fields that are empty in the
%          original event. If the new event does not match, do nothing.</td></tr>
% <tr><td><tt>'Replace'</tt></td>
%      <td>If the new event matches the existing event, replace the old
%          event with the new one. If the new event does not match, do nothing.</td></tr>
% <tr><td><tt>'Merge'</tt></td>
%      <td>If the new event matches the existing event, update it
%          as with 'Update'. If the new event does not match,
%           include it as a new event.</td></tr>
% <tr><td><tt>'None'</tt></td>
%      <td>If the new event matches the existing event, update it
%          as with 'Update'. If the new event does not match,
%           include it as a new event.</td></tr>
% </table>
% </html>
%
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
% <blockBoxPlot_help.html |visviews.blockBoxPlot|>, 
% <blockImagePlot_help.html |visviews.blockImagePlot|>, 
% <clickable_help.html |visviews.clickable|>, 
% <configurable_help.html |visprops.configurable|>,
% <cursorExplorable_help.html |visviews.cursorExplorable|>, and
% <resizable_help.html |visviews.resizable|> 
%


%% 
% Copyright 2013 Kay A. Robbins, University of Texas at San Antonio