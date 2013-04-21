% tagdir
% Allows a user to tag an entire tree directory of similar EEG .set files.
%
% Usage:
%   >>  [eTags, fPaths] = tagdir(inDir)
%   >>  [eTags, fPaths] = tagdir(inDir, 'key1', 'value1', ...)
%
%% Description
% [eTags, fPaths] = tageeg(inDir)extracts a consolidated eventTags object 
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
function [eTags, fPaths] = tagdir(inDir, varargin)
    % Tag all of the EEG files in a directory tree
    parser = inputParser;
    parser.addRequired('InDir', @(x) (~isempty(x) && ischar(x)));
    parser.addParamValue('BaseTagsFile', '', ...
        @(x)(isempty(x) || (ischar(x) && exist(x, 'file') && ...
            ~isempty(eventTags.loadTagsFile(x)))));
    parser.addParamValue('DoSubDirs', true, @islogical);
    parser.addParamValue('Match', 'code', ...
        @(x) any(validatestring(lower(x), {'code', 'label', 'both'})));
    parser.addParamValue('OnlyType', true, @islogical);
    parser.addParamValue('PreservePrefix', false, @islogical);
    parser.addParamValue('Synchronize', true, @islogical);
    parser.addParamValue('TagFileName', '', ...
         @(x)(isempty(x) || (ischar(x))));
    parser.addParamValue('UpdateType', 'tagsonly', ...
          @(x) any(validatestring(lower(x), ...
          {'merge', 'replace', 'onlytags', 'update', 'none'})));
    parser.addParamValue('UseGUI', true, @islogical);
   
    parser.parse(inDir, varargin{:});
    p = parser.Results;
    % Consolidate all of the tags from the input directory and base
    eTags = eventTags('', '', 'Match', p.Match, 'PreservePrefix', ...
                      p.PreservePrefix);
    fPaths = getFileList(p.InDir, '.set', p.DoSubDirs);
    for k = 1:length(fPaths) % Assemble the list
        eegTemp = pop_loadset(fPaths{k});
        eTagsNew = geteegtags(eegTemp, 'Match', p.Match, ...
                   'PreservePrefix', p.PreservePrefix);
        eTags.mergeEventTags(eTagsNew, 'Merge');
    end
    baseTags = eventTags.loadTagFile(p.BaseTagsFile);
    eTags = tagEvents(eTags, 'BaseTags', baseTags, ...
        'Match', p.Match, 'PreservePrefix', p.PreservePrefix, ...
        'UpdateType', p.UpdateType, 'UseGUI', p.UseGUI, ...
        'Synchronize', p.Synchronize);

    % Save the tags file for next step
    if ~isempty(p.TagFileName) || ...
        ~eventTags.saveTagFile(p.TagFileName, 'eTags')
        bName = tempname;
        warning('tagEEGDir:invalidFile', ...
            ['Couldn''t save eventTags to ' p.TagFileName]);
        eventTags.saveTagFile(bName, 'eTags')
    else 
        bName = p.TagFileName;
    end
 

    if isempty(fPaths) || strcmpi(p.UpdateType, 'none')
        return;
    end
    % Rewrite all of the EEG files with updated tag information
    for k = 1:length(fPaths) % Assemble the list
        teeg = pop_loadset(fPaths{k});
        teeg = tageeg(teeg, 'BaseTagsFile', bName, ...
              'UpdateType', p.UpdateType, 'UseGUI', false, ...
              'Synchronize', p.Synchronize);
        pop_saveset(teeg, 'filename', fPaths{k});
    end
end % tagEEGDir