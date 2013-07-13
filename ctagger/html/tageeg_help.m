%% cTagger.tagEEG
% Tag an EEGLAB |EEG| structure using initial tags and cTagger GUI
%
%% Syntax
%     EEG = cTagger.tagEEG(EEG)
%     EEG = cTagger.tagEEG(EEG, 'key1', 'value1', ...)
%% Description
% |EEG = cTagger.tagEEG(EEG)| tags the EEGLAB |EEG| structure. It first
% extracts any existing tag information from the |EEG.etc.hedEventTags|
% string if it exists. Then |tagEEG| creates events for any event
% types that appear in |EEG.event| or |EEG.urevent| but are not in the
% pretagged information. Finally, |tagEEG| consolidates this information
% and uses it to populate the cTagger GUI, allowing the user to edit
% the tagging information. If the user clicks on |Submit|, the edited
% tagging information is stored in |EEG.etc.hedEventTags|, overwriting
% the previous version. If the user clicks on |Cancel| or quits the GUI,
% the |EEG| structure is not modified.
%
% |EEG = cTagger.tagEEG(EEG, 'key1', 'value1', ...)| defines its operation
% with non-default options as given by the following name/value pairs:
% 
%
% <html>
% <table>
% <thead><tr><td><strong>Name</strong></td><td><strong>Value<strong></td></tr></thead>
% <tr><td><tt>'BaseTags'</tt></td>
%      <td><tt>eventTags</tt> object containing tag initialization</td></tr>
% <tr><td><tt>'UpdateType'</tt></td>
%      <td>One of the values <tt>'Merge'</tt>, <tt>'Replace'</tt>, ...
%          <tt>'TagsOnly'</tt> or <tt>'Update'</tt> specifying how
%              duplicate events and tags are merged. The default
%              is <tt>'TagsOnly'</tt> (see below for more details).</td></tr>
% <tr><td><tt>'UseGUI'</tt></td>
%      <td>If true (the default), the CTagger GUI will be brought up to allow
%          users to modify the tagging information.</td></tr>
% </table>
% </html>
%


%% Example 1
% Tag the EEGLAB EEGEpoch EEG structure, using the GUI
   load 'EEGEpoch.mat';
   EEGEpoch = tageeg(EEGEpoch);


%% Class documentation
% Execute the following in the MATLAB command window to view the class 
% documentation for |cTagger|:
%
%    doc cTagger
%
%% See also
% <cTagger_getEEGEventTags_help.html |cTagger.getEEGEventTags|>,
% <cTagger_getEEGDirEventTags_help.html |cTagger.getEEGDirEventTags|>, 
% <cTagger_tagEEGDir_help.html |cTagger.tagEEGDir|>, 
% <cTagger_tagThis_help.html |cTagger.tagThis|>, 
%

%% 
% Copyright 2013 Thomas C. Rognon and Kay A. Robbins, University of Texas at San Antonio