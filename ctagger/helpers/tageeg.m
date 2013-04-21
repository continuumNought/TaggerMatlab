% tageeg
% Allows a user to tag an EEGLAB EEG structure
%
% Usage:
%   >>  [EEG, eTags] = tageeg(EEG)
%   >>  [EEG, eTags] = tageeg(EEG, 'key1', 'value1', ...)
%
%% Description
% [eTags, fPaths] = tageeg(EEG) creates an eventTags object called eTags
% from the specified EEG structure using only the 'type' field of the
% EEG.event and EEG.urevent structures. After existing event tags are
% extracted from the EEG structure, the ctagger GUI is launched in
% synchronous mode, meaning that it behaves like a modal dialog and must
% be closed before execution continues. 
%
%
% |[eTags, fPaths] = tageeg(EEG, 'key1', 'value1', ...)| specifies 
% optional name/value parameter pairs:
%   'BaseTagsFile'   A file containing an eventTags object to be used
%                    for initial tag information. The default is an 
%                    eventTags object with the default HED XML and no tags.
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
%   'UpdateType'     Indicates how tags are merged with initial tags. The
%                    options are: 'merge', 'replace', 'onlytags' (default),
%                    'update' or 'none' as decribed below.
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
%    'none'           Don't use the base tags to update the information 
%                     in the output EEG structure.
%
% See also: tagdir and tagstudy
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
% $Log: tageeg.m,v $
% $Revision: 1.0 21-Apr-2013 09:25:25 krobbins $
% $Initial version $
%
function [EEG, eTags] = tageeg(EEG, varargin)
    % Parse the input arguments
    parser = inputParser;
    parser.addRequired('EEG', @(x) (isempty(x) || ...
        isstruct(EEG) || isfield(EEG, 'event') || ...
        isstruct(EEG.event) || isfield(EEG.event, 'type') || ...
        isfield(EEG, 'urevent') || isstruct(EEG.urevent) && ...
        isfield(EEG.urevent, 'type')));
    parser.addParamValue('BaseTagsFile', '', ...
        @(x)(isempty(x) || (ischar(x))));
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
    parser.parse(EEG, varargin{:});
    p = parser.Results;
    
    % Get the existing tags for the EEG
    eTags = findtags(p.EEG, 'Match', p.Match, ...
            'PreservePrefix', p.PreservePrefix);
    baseTags = eventTags.loadTagFile(p.BaseTagsFile);
    eTags = tagEvents(eTags, 'BaseTags', baseTags, ...
            'UpdateType', p.UpdateType, 'UseGUI', p.UseGUI, ...
            'Synchronize', p.Synchronize);
    EEG.etc.eventTags = eTags.getJson();    
end % tageeg