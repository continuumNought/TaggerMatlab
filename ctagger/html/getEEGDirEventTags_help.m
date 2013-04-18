%% cTagger.getEEGDirEventTags
% Create a summary eventTags object for the EEG files in a directory tree
%
%% Syntax
%     [eTags, fPaths] = cTagger.getEEGDirEventTags(inDir)
%     [eTags, fPaths] = cTagger.getEEGDirEventTags(inDir, 'key1', 'value1', ...)
%
%% Description
% |[eTags, fPaths] = cTagger.getEEGDirEventTags(inDir, doSubDirs)| returns 
% an eventTags object called |eTags| that contains a consolidated version
% of the events and hed hierarchies. From all of the |.set| files in
% the directory |inDirs|. If |doSubDirs| is |true|, then |.set| then
% |getEEGDirEventTags| recursively includes all |.set| files in the
% directory tree. The |fPaths| variable is a cell array containing the
% full path names of the |.set| files that have been included.
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
%% Processing
% The |cTagger.getEEGDirEventTags(inDir, doSubDirs)| includes all of the
% event codes from both the |EEG.events| and |EEG.urevents| structures
% as well as any previous tagging information.
%
% Previous tagging information is stored in the |EEG.etc.eventHedTags|
% variable as a JSON string. (See the documentation of the |eventTags|
% object for further information on the format.)
%
%% Workflow
% The |cTagger.getEEGDirEventTags| method is called by itself to obtain
% a consolidated eventTags object for a collection of EEG datasets that
% have the same or similar event structures. The consolidated event 
% structure is used as part of the |cTagger.tagEEGDir| method, which
% consolidates the event information, allows the user to tag, and then
% propagates the tags to the individual datasets. However, the
% |cTagger.getEEGDirEventTags| does not bring up a GUI or modify the 
% EEG datasets. It is an information gathering operation.
% 

%% Example 1
% Consolidate the events from EEG datasets in the current directory tree
   eTags = cTagger.getEEGDirEventTags(pwd);


%% Class documentation
% Execute the following in the MATLAB command window to view the class 
% documentation for |cTagger|:
%
%    doc cTagger
%
%% See also
% <cTagger_getEEGEventTags_help.html |cTagger.getEEGEventTags|>,
% <cTagger_tagEEG_help.html |cTagger.tagEEG|>, 
% <cTagger_tagEEGDir_help.html |cTagger.tagEEGDir|>, 
% <cTagger_tagThis_help.html |cTagger.tagThis|>, 
%

%% 
% Copyright 2013 Thomas C. Rognon and Kay A. Robbins, University of Texas at San Antonio