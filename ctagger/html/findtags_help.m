%% findTags
% Create an eventTags object for the existing tags in an EEG structure
%
%% Syntax
%    eTags = findtags(EEG)
%    eTags = findtags(EEG, 'key1', 'value1', ...)
%
%% Description
% |eTags = findtags(EEG)| extracts an eventTags object representing the
% events and their tags for the EEG structure.
%
% |eTags = findtags(EEG, 'key1', 'value1', ...)| specifies 
% optional name/value parameter pairs:
%
% <html>
% <table>
% <thead><tr><td>Name</td><td>Description of action</td></tr></thead>
% <tr><td><tt>'Match'</tt></td>
%     <td>Specifies the event matching criteria:
%    <tt>'code'</tt> (default), <tt>'label'</tt>, 
%    or <tt>'both'</tt> (see notes).</td></tr>
% <tr><td><tt>'OnlyType'</tt></td>
%     <td>If |true| (default), tag only based on the |type| field of
%           |EEG.event| and |EEG.urevent|, ignoring other fields
%           of these structures.</td></tr>
% <tr><td><tt>'PreservePrefix'</tt></td>
%     <td>If |false| (default), tags of the same event type that
%        share prefixes are combined and only the most specific
%        is retained (e.g., /a/b/c and /a/b become just
%        /a/b/c). If |true|, then all unique tags are retained.</td></tr>
% </table>
% </html>
%
%% Notes
% The <tt>match</tt> parameter determines whether two events match. There are
% three possible strategies:  
% 
% <html>
% <ul>
% <li> <tt>code</tt> - (the default) events match if their codes match</li>
% <li> <tt>label</tt> - events match if their labels match</li>
% <li> <tt>both</tt> - events match if both their labels and codes match</li>
% </ul>
% </html>
%
%% Example 1
% Create an eventTags object representing the event tagging of an EEG structure
   load 'EEGEpoch.mat';
   eTags = findtags(EEGEpoch);

%%
% The |eTags| eventTags object will contain all of the unique event
% type fields present in the |EEG.events| and |EEG.urevents| of the
% EEG structure since the default |'OnlyType'| argument is |true|.
%

%% Class documentation
% Execute the following in the MATLAB command window to view the class 
% documentation for |findtags|:
%
%    doc findtags
%
%% See also
% <eventTags_help.html |eventTags|>,
% <tagdir_help.html |tagdir|>,
% <tageeg_help.html |tageeg|>, 
% <tagevents_help.html |tagevents|>, 
% <tagstudy_help.html |tagstudy|>
%

%% 
% Copyright 2013 Thomas C. Rognon and Kay A. Robbins, University of Texas at San Antonio