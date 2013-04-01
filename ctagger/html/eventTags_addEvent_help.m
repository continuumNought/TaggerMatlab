%% visviews.elementBoxPlot
% Display a boxplot of block function values by element
%
%% Syntax
%     eventExists = addEvent(obj, event, mergeType)
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
%           code: '1'
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
% <tr><td><tt>'TagsOnly'</tt></td>
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
% </table>
% </html>
%
%

%% Example 1
% Create an element boxplot of kurtosis for EEG data

%% Notes
%
% * If |manager| is empty, the class defaults are used to initialize.
% * If |key| is empty, the class name is used to identify in GUI
% configuration.
%
%% Class documentation
% Execute the following in the MATLAB command window to view the class 
% documentation for |cTagger|:
%
%    doc cTagger
%
%% See also
% <axesPanel_help.html |visviews.axesPanel|>,
% <blockBoxPlot_help.html |visviews.blockBoxPlot|>, 
% <blockImagePlot_help.html |visviews.blockImagePlot|>, 
% <clickable_help.html |visviews.clickable|>, 
% <configurable_help.html |visprops.configurable|>,
% <cursorExplorable_help.html |visviews.cursorExplorable|>, and
% <resizable_help.html |visviews.resizable|> 
%


%% 
% Copyright 2013 Kay A. Robbins, University of Texas at San Antonio