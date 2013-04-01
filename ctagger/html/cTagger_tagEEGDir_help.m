%% cTagger.tagEEGDir
% Allows a user to tag an entire directory of similar EEG .set files.
%
%% Syntax
%     [eTags, fPaths] = cTagger.tagEEGDir(inDir)
%     [eTags, fPaths] = cTagger.tagEEGDir(inDir, 'key1', 'value1', ...)
%
%% Description
% |[eTags, fPaths] = cTagger.tagEEGDir(inDir)| 
% extracts a consolidated eventTags object from the directory |inDir| by calling
% |cTagger.getEEGDirEventTags|. First the events and tags from all
% EEGLAB .set files are extracted and consolidated into a single eventTags
% object. A previously defined |eBaseTags| eventTags object is merged. The
% |updateType| controls the way the events are combined. If |useGUI| is
% true, the user can than modify this consolidated eventTags object using
% the |cTagger| GUi. Once the user has completed editing and closed the
% GUI, the event information in all of the .set files is updated. If
% |doSubDirs| is true, all .set files in the |inDir| directory tree are
% affected. If |doSubDirs| is false, then only the .set files in the |inDir|
% tree are used.  
%
% The final, consolidated and edited |eventTags| object is returned in |eTags|
% and |fPaths| is a cell array containing the full path names of all of the
% .set files that were affected.
%
%
%
% |[eTags, fPaths] = cTagger/tagEEGDir(inDir, 'key1', 'value1', ...)| specifies 
% optional name/value parameter pairs:
%
% <html>
% <table>
% <thead><tr><td><strong>Name</strong></td><td><strong>Value<strong></td></tr></thead>
% <tr><td><tt>'BaseTags'</tt></td>
%      <td><tt>eventTags</tt> object containing tag initialization</td></tr>
% <tr><td><tt>'DoSubDirs'</tt></td>
%      <td>if true (the default) includes all <tt>.set</tt> files
%      in the <tt>inDir</tt> directory tree. If false, only process
%      files in the immediate <tt>inDir</tt> directory.</td></tr>
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
%
% <html>
% <table class="PROPERTYTABLE">
% <tr><td><strong>Value</strong></td><td><strong>Description</strong></td></tr>
% <tr><td><tt>'Merge'</tt></td> <td>If an event with that key is not part of this
%                     object, add it as is.</td></tr> 
% <tr><td><tt>'Replace'</tt></td> <td>If an event with that key is not part of this
%                     object, do nothing. Otherwise, if an event with that
%                     key is part of this object then completely replace 
%                     that event with the new one.</td></tr>
% <tr><td><tt>'TagsOnly'</tt></td> <td>If an event with that key is not part of this
%                     object, do nothing. Otherwise, if an event with that
%                     key is part of this object, then update the tags of 
%                     the matching event with the new ones from this event,
%                     using the PreservePrefix value to determine how to
%                     combine the tags.</td></tr>
% <tr><td><tt>'Update'</tt></td> <td>If an event with that key is not part of this
%                     object, do nothing. Otherwise, if an event with that
%                     key is part of this object, then update the tags of 
%                     the matching event with the new ones from this event,
%                     using the PreservePrefix value to determine how to
%                     combine the tags. Also update any empty code, label
%                     or description fields by using the values in the
%                     input event.</td></tr>
% </table>
% </html>
%

%% Example 1
% Tag all of the .set files in the directory c:\Data
   [eTags, fPaths] = cTagger.tagEEGDir('c:\Data');
                              
%%
% In the example, the events from all of the EEG .set files in  
% |'C:\Data'| and its subdirectories will be consolidated into a single
% |eventTags| object and the information presented to the user for
% editing. When user has completed editing, the |.set| files will be
% updated with new tags. Since the update is |'TagsOnly'|, the 
% |EEG.etc.hedEventTags| string will only contain events that are
% present in that file.
%
     
%% Dependencies
% This method uses the EEGLAB |pop_loadset| to load the |.set| files
% and the EEGLAB |pop_saveset| to save the modified |EEG| structures
% after retagging. Therefore EEGLAB must be in the path.
%
%% Class documentation
% Execute the following in the MATLAB command window to view the class 
% documentation for |cTagger|:
%
%    doc cTagger
%
%% See also
% <cTagger_getEEGDirEventTags_help.html |cTagger.getEEGDirEventTags|>,
% <cTagger_getEEGEventTags_help.html |cTagger.getEEGEventTags|>,
% <cTagger_tagEEG_help.html |cTagger.tagEEG|>, 
% <cTagger_tagThis_help.html |cTagger.tagThis|>, 
%

%% 
% Copyright 2013 Thomas C. Rognon and Kay A. Robbins, University of Texas at San Antonio