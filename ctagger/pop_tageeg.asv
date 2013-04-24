% pop_tageeg provides a GUI for annotating events in the EEGLAB EEG structure 
%
% Usage:
%   >>  [EEGOUT, com] = pop_tageeg(EEG)
%
% [EEGOUT, com] = pop_tageeg(EEG) takes an input EEGLAB EEG structure,
% brings up a GUI to enter parameters for tageeg, and calls
% tageeg to extracts the EEG structure's tags, if any. The tageeg
% function then brings up the ctagger GUI to allow users to modify the
% tags.
%
% Notes:
%  -  pop_tageeg() is meant to be used as the callback under the 
%     EEGLAB Edit menu. It is a singleton and clicking
%     the menu item again will not create a new window if one already
%     exists.
%  -  The function first brings up a GUI to enter the parameters to 
%     override the default values for tageeg and then optionally allows
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

% $Log: pop_tageeg.m,v $
% Revision 1.0 21-Apr-2013 09:25:25  kay
% Initial version
%


function [EEG, com] = pop_tageeg(EEG) 
% Create the tagger for a single EEG file
    com = '';       

    % Display help if inappropriate number of arguments
    if nargin < 1 
        help pop_tageeg;
        return;
    end;

    % Get the tagger input parameters
    [baseTagsFile,  match, onlyType,  preservePrefix, ...
          saveTagsFile, updateType, useGUI, cancelled] = tageeginputs();     
    if cancelled
        return;
    end

    % Tag the EEG structure and return the command string
    EEG = tageeg(EEG, 'BaseTagsFile', baseTagsFile, 'Match', match, ...
                 'OnlyType', onlyType, 'PreservePrefix', preservePrefix, ...
                 'TagFileName', saveTagsFile,'UpdateType', updateType, ...
                 'UseGUI', useGUI, 'Synchronize', false);
    formatString = ['%s = pop_tageeg(%s, ''BaseTagsFile'', ''' ...
           baseTagsFile ''', ''Match'', ''' match, ''', ' ...
           '''OnlyType'', ' logical2str(onlyType) ', ' ...
           '''PreservePrefix'', ' logical2str(preservePrefix) ', ' ...
           '''Synchronize'', ' logical2str(false) ', ' ...
           '''TagFileName'', ''' saveTagsFile ''', ' ...
           '''UpdateType'', ''' updateType ''', ' ...
           '''UseGui'', ' logical2str(useGUI) ')'];
    com = sprintf(formatString, inputname(1), inputname(1));
end % pop_tageeg

function s = logical2str(b)
    if b 
        s = 'true';
    else
        s = 'false';
    end
end % logical2str

  