% pop_tagdir opens ctagger GUI to tag a directory tree of EEG files
%
% Usage:
%   >>  [eTags, fPaths, com] = pop_tagdir()
%
% Outputs:
%    eTags  - an eventTags object containing consolidated tags
%    fPaths - full path names of all EEG files
%    com    - string containing call to tagdir with all parameters
%
% Notes:
%  -  pop_tagdir() is meant to be used as the callback under the 
%     EEGLAB File menu. It is a singleton and clicking
%     the menu item again will not create a new window if one already
%     exists.
%  -  The function first brings up a GUI to enter the parameters to 
%     override the default values for tagdir and then optionally allows
%     the user to use the ctagger GUI to modify the tags.
% 
% See also:
%   eeglab, tageeg, tagdir, tagstudy, and eegplugin_ctagger
%

%
% Copyright (C) 2012-2013 Thomas Rognon tcrognon@gmail.com and
% Kay Robbins, UTSA, kay.robbins@utsa.edu
%
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
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

% $Log: pop_tagdir.m,v $
% Revision 1.0 21-Apr-2013 09:25:25  kay
% Initial version
%


function [eTags, fPaths, com] = pop_tagdir()    
% Create the tagger for this EEG set
    eTags = '';
    fPaths = '';
    com = '';
    [inDir, baseTagsFile, doSubDirs, match, onlyType, ...
    preservePrefix, updateType, saveTagsFile, useGUI, cancelled] =  ...
                        tagdirinputs();
    if cancelled
        return;
    end
    [eTags, fPaths] = tagdir(inDir, 'BaseTagsFile', baseTagsFile, ...
                      'DoSubDirs', doSubDirs, 'Match', match, ...
                      'OnlyType', onlyType, 'PreservePrefix', preservePrefix, ...
                      'Synchronize', false, 'TagFileName', saveTagsFile, ...
                      'UpdateType', updateType, 'UseGUI', useGUI);

    com = char(['tagdir(''' inDir ''', ' ...
                '''BaseTagsFile'', ''' baseTagsFile ''', '...
                '''DoSubDirs'', ' logical2str(doSubDirs) ', ' ...
                '''Match'', ''' match, ''', ' ...
                '''OnlyType'', ' logical2str(onlyType) ', ' ...
                '''PreservePrefix'', ' logical2str(preservePrefix) ', ' ...
                '''Synchronize'', ' logical2str(false) ', ' ...
                '''TagFileName'', ''' saveTagsFile ''', ' ...
                '''UpdateType'', ''' updateType ''', ' ...
                '''UseGui'', ' logical2str(useGUI) ')']);  
end % pop_tagdir

function s = logical2str(b)
    if b 
        s = 'true';
    else
        s = 'false';
    end
end
  