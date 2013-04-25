% tagdir
% Allows a user to tag an entire tree directory of similar EEG .set files.
%
% Usage:
%   >>  [eTags, fPaths] = tagdir(inDir)
%   >>  [eTags, fPaths] = tagdir(inDir, 'key1', 'value1', ...)
%
%% Description
% [eTags, fPaths] = tagdir(inDir)extracts a consolidated eventTags object 
% from the EEGLAB .set files from the directory tree inDir. 
% First the events and tags from all EEGLAB .set files are extracted and 
% consolidated into a single eventTags object by merging all of the 
% existing tags. Then the ctagger GUI is displayed so that users can
% edit/modify the tags. The GUI is launched in synchronous mode, meaning 
% that it behaves like a modal dialog and must be closed before execution 
% continues. Finally the tags for each EEG file are updated.
%
% The final, consolidated and edited eventTags object is returned in eTags
% and fPaths is a cell array containing the full path names of all of the
% .set files that were affected. If fPaths is empty, then eTags will also
% be empty.
%
%
% [eTags, fPaths] = tagdir(EEG, 'key1', 'value1', ...) specifies 
% optional name/value parameter pairs:
%   'BaseTagsFile'   A file containing an eventTags object to be used
%                    for initial tag information. The default is an 
%                    eventTags object with the default HED XML and no tags.
%   'DoSubDirs'      If true the entire inDir directory tree is searched.
%                    If false, only the inDir directory is searched.
%   'Match'          A string with event matching criteria:
%                    'code' (default), 'label', or 'both'         
%   'OnlyType'       If true (default), only tag based on unique event types
%                    and not on the other fields of EEG.event and
%                    EEG.urevent.
%   'PreservePrefix' If false (default), tags of the same event type that
%                    share prefixes are combined and only the most specific
%                    is retained (e.g., /a/b/c and /a/b become just
%                    /a/b/c). If true, then all unique tags are retained.
%   'Synchronize'    If true (default), the ctagger GUI is run synchronously so
%                    no other MATLAB commands can be issued until this GUI
%                    is closed. A value of false is used when this function
%                    is being called as a menu item from another GUI.
%   'TagFileName'    Name containing the name of the file in which to
%                    save the consolidated eventTags object for future use.
%   'UpdateType'     Indicates how tags are merged with initial tags if the
%                    tagging information is to be rewritten to the EEG
%                    files. The options are: 'merge', 'replace', 
%                    'onlytags' (default), 'update' or 'none'.
%   'UseGUI'         If true (default), the ctagger GUI is displayed after
%                    initialization.
%
% Description of update options:
%    'merge'         If an event with that key is not part of this
%                     object, add it as is.
%    'replace'       If an event with that key is not part of this
%                     object, do nothing. Otherwise, if an event with that
%                     key is part of this object then completely replace 
%                     that event with the new one.
%    'onlytags'      If an event with that key is not part of this
%                     object, do nothing. Otherwise, if an event with that
%                     key is part of this object, then update the tags of 
%                     the matching event with the new ones from this event,
%                     using the PreservePrefix value to determine how to
%                     combine the tags.
%    'update'         If an event with that key is not part of this
%                     object, do nothing. Otherwise, if an event with that
%                     key is part of this object, then update the tags of 
%                     the matching event with the new ones from this event,
%                     using the PreservePrefix value to determine how to
%                     combine the tags. Also update any empty code, label
%                     or description fields by using the values in the
%                     input event.
%    'none'           Don't do any updating
%
% See also: tageeg and tagstudy
%

%1234567890123456789012345678901234567890123456789012345678901234567890

% Copyright (C) Kay Robbins and Thomas Rognon, UTSA, 2011-2013, krobbins@cs.utsa.edu
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
%
% $Log: tagdir.m,v $
% $Revision: 1.0 21-Apr-2013 09:25:25 krobbins $
% $Initial version $
%
function [eTags, fPaths] = tagdir(inDir, varargin)
    % Parse the input arguments
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
    parser.addParamValue('UpdateType', 'onlytags', ...
          @(x) any(validatestring(lower(x), ...
          {'merge', 'replace', 'onlytags', 'update', 'none'})));
    parser.addParamValue('UseGUI', true, @islogical);
    parser.parse(inDir, varargin{:});
    p = parser.Results;
    

    fPaths = getfilelist(p.InDir, '.set', p.DoSubDirs);
    if isempty(fPaths)
        eTags = '';
        return;
    end
    
    % Consolidate all of the tags from the input directory and base
    eTags = eventTags('', '', 'Match', p.Match, 'PreservePrefix', ...
                      p.PreservePrefix);
    for k = 1:length(fPaths) % Assemble the list
        eegTemp = pop_loadset(fPaths{k});
        eTagsNew = findtags(eegTemp, 'Match', p.Match, ...
                   'PreservePrefix', p.PreservePrefix);
        eTags.mergeEventTags(eTagsNew, 'Merge');
    end
    baseTags = eventTags.loadTagFile(p.BaseTagsFile);
    eTags = tagevents(eTags, 'BaseTags', baseTags, ...
        'UpdateType', p.UpdateType, 'UseGUI', p.UseGUI, ...
        'Synchronize', p.Synchronize);

    % Save the tags file for next step
    if ~isempty(p.TagFileName) && ...
        ~eventTags.saveTagFile(p.TagFileName, 'eTags')
        bName = tempname;
        warning('tagdir:invalidFile', ...
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
              'Match', p.Match, 'PreservePrefix', p.PreservePrefix, ...
              'Synchronize', p.Synchronize, ...
              'UpdateType', p.UpdateType, 'UseGUI', false);
        pop_saveset(teeg, 'filename', fPaths{k});
    end
end % tagdir