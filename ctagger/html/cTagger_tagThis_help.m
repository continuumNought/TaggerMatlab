%% cTagger.tagThis
% Update and existing eventTags object 
%
%% Syntax
%      eTags = tagThis(eTags)
%      eTags = tagThis(eTags, 'key1', 'value1', ...)
%
%% Description
% |eTags = tagThis(eTags)| returns an updated version of the |eventTags| 
% object called |eTags|. The
% events from |eTagsBase| are merged first added to |eTags| using the
% update strategy specified by |updateType|. If |useGUI| is true, the
% updated version of |eTags| is then used to populate the cTagger GUI,
% allowing users to make additional changes. 
%
%
% |eTags = cTagger/tagThis(eTags, 'key1', 'value1', ...)| specifies 
% optional name/value parameter pairs:
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
% The values of the |updateType| flag are:
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

%% Workflow
% The |cTagger.tagThis| method is called by itself to merge events and
% tags from another eventTags object or to create tags using the 
% cTagger GUI.
%
%
%% Example 1
% Update the event tags in eTags1 based on those in eTags2:
   [h1, e1] = eventTags.split(';1, code 1, event 1, /a/b/c, /def', false)
   eTags1 = eventTags(h1, e1);
   e2 = eventTags.json2Events(['[{"code":"1", "label":"code 1",' ...
       '"description":"event 1", "tags":[ "/light/stimulus"]}]'])
   eTags2 = eventTags('', e2);
   eTags1 = cTagger.tagThis(eTags1, 'BaseTags', eTags2, 'UseGUI', false);
   events = eTags1.getEvents() 
   event1 = events{1}    % Just show the output here
   
%%
% The first pair of statements creates an |eventTags| object from a
% a text string that has an empty hedXML and a single event with
% two tags. The |eventTags.split| function splits this string into an
% the string specifying the hed XML hierarch and an events structure array.
%
% The |eventTags.json2Events| function takes a JSON string encoding one
% or more events and creates an events structure array for the events.
% 
% The |cTagger.tagThis| function then merges the tags from |eTags2| into the 
% |eTags1| object. After this code has completed, the event with code 1 
% will have 3 tags: |'/a/b/c'|, |'/def'| and |'/light/stimulus'|.

%% Class documentation
% Execute the following in the MATLAB command window to view the class 
% documentation for |cTagger|:
%
%    doc cTagger
%
%% See also
% <cTagger_getEEGDIREventTags_help.html |cTagger.getEEGEventTags|>,
% <cTagger_getEEGEventTags_help.html |cTagger.getEEGEventTags|>,
% <cTagger_tagEEG_help.html |cTagger.tagEEG|>, 
% <cTagger_tagEEGDir_help.html |cTagger.tagEEGDir|>, 
% <cTagger_tagThis_help.html |cTagger.tagThis|>, 
%

%% 
% Copyright 2013 Thomas C. Rognon and Kay A. Robbins, University of Texas at San Antonio