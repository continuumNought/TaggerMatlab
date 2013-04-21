
% tagdir
% Allows a user to tag an entire tree directory of similar EEG .set files.
%
% Usage:
%   >>  [EEG, eTags] = tageeg(EEG)
%   >>  [EEG, eTags] = tageeg(EEG, 'key1', 'value1', ...)
%
%% Description
% [eTags, fPaths] = tageeg(EEG) creates  
% from the directory inDir. First the events and tags from all
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
% |[eTags, fPaths] = tageeg(EEG, 'key1', 'value1', ...)| specifies 
% optional name/value parameter pairs:
%   'BaseTagsFile'   File name containing a starting eventTags object
%                    (created from previous tagging sessions). Default is
%                    an empty eventTags object using the default hed xml.
%   'OnlyType'       If true (default), only tag based on unique event types.
%   'Synchronize'    If true (default), the ctagger GUI is run synchronously so
%                    no other MATLAB commands can be issued until this GUI
%                    is closed.
%   'UpdateType'     Indicates how tags are merged with initial tags. The
%                    options are: 'Merge', 'Replace', 'TagsOnly' (default)
%                    or 'Update' as decribed below.
%   'UseGUI'         If true (default), the ctagger GUI is displayed after
%                    initialization.
%
% Description of update options:
%    'Merge'         If an event with that key is not part of this
%                     object, add it as is.
%    'Replace'       If an event with that key is not part of this
%                     object, do nothing. Otherwise, if an event with that
%                     key is part of this object then completely replace 
%                     that event with the new one.
%    'TagsOnly'      If an event with that key is not part of this
%                     object, do nothing. Otherwise, if an event with that
%                     key is part of this object, then update the tags of 
%                     the matching event with the new ones from this event,
%                     using the PreservePrefix value to determine how to
%                     combine the tags.
% <table class="PROPERTYTABLE">
% <tr><td><strong>Value</strong></td><td><strong>Description</strong></td></tr>
% <tr><td><tt>'Merge'</tt></td> <td></td></tr> 
% <tr><td><tt>'Replace'</tt></td> <td>I</td></tr>
% <tr><td><tt>'TagsOnly'</tt></td> <td></td></tr>
% <tr><td><tt>'Update'</tt></td> <td>If an event with that key is not part of this
%                     object, do nothing. Otherwise, if an event with that
%                     key is part of this object, then update the tags of 
%                     the matching event with the new ones from this event,
%                     using the PreservePrefix value to determine how to
%                     combine the tags. Also update any empty code, label
%                     or description fields by using the values in the
%                     input event.</td></tr>
% </table>
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
function [EEG, eTags] = tageeg(EEG, varargin)
    % Tag this EEG using eTagsBase as the structure
    parser = inputParser;
    parser.addRequired('EEG', @(x) (isempty(x) || isstruct(x)));
    parser.addParamValue('BaseTagsFile', '', ...
        @(x)(isempty(x) || (ischar(x))));
    parser.addParamValue('Match', 'Code', ...
        @(x) any(validatestring(x, {'code', 'label', 'both'})));
    parser.addParamValue('OnlyType', true, @islogical);
    parser.addParamValue('PreservePrefix', false, @islogical);
    parser.addParamValue('Synchronize', true, @islogical);
    parser.addParamValue('TagFileName', '', ...
         @(x)(isempty(x) || (ischar(x))));
    parser.addParamValue('UpdateType', 'TagsOnly', ...
          @(x) any(validatestring(x, ...
          {'Merge', 'Replace', 'TagsOnly', 'Update', 'NoUpdate'})));
    parser.addParamValue('UseGUI', true, @islogical);

    parser.parse(EEG, varargin{:});
    p = parser.Results;
    eTags = geteegtags(p.EEG, 'Match', p.Match, ...
            'PreservePrefix', p.PreserfePrefix);
    baseTags = eventTags.loadTagFile(p.BaseTagsFile);
    eTags = tagEvents(eTags, 'BaseTags', baseTags, ...
            'UpdateType', p.UpdateType, 'UseGUI', p.UseGUI, ...
            'Synchronize', p.Synchronize);
end % tagEEG