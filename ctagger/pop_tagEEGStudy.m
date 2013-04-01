% pop_tagEEGStudy opens the ctagger GUI as a singleton callback for EEGLAB
%
% Usage:
%   >>  EEGOUT = pop_ctagger(EEG)
%
% Inputs:
%    EEG     EEG dataset to be tagger
%    HEDXML  XML specification of the hierarchy tag structure
%
% Outputs:
%   EEGOUT  - the input EEG dataset
% 
% The pop_ctagger provides a GUI for annotating events in EEG structure 
%
% Notes:
%  -  pop_ctagger() is meant to be used as the callback under the 
%     EEGLAB Edit menu. It is a singleton and clicking
%     the menu item again will not create a new window if one already
%     exists.
% 
% See also:
%   eeglab, ctagger, and eegplugin_ctagger
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

% $Log: pop_ctagger.m,v $
% Revision 1.0 03-Feb-2013 10:22:05  kay
% Initial version
%


function [eTags, com] = pop_tagEEGStudy()    
% Create the tagger for this EEG study
[studyFile, baseTagsFile, updateType, onlyType, saveTagsFile, useGUI, ...
    cancelled] = getTagStudyInputs();
if cancelled
    eTags = '';
    com = '';
else
    eTags = tagEEGStudy(studyFile, 'BaseTagsFile', baseTagsFile, ...
                  'OnlyType', onlyType, ...
                  'TagFileName', saveTagsFile, 'UpdateType', updateType, ...
                  'UseGUI', useGUI);
              
    com = char(['tagEEGStudy(''' studyFile ''', ' ...
            '''BaseTagsFile'', ''' baseTagsFile ''', '...
            '''OnlyType'', ' ...
             num2str(onlyType) ', ''TagFileName'', ''' saveTagsFile ''', ' ...
            '''UpdateType'', ''' updateType ''', ', ...
            '''UseGui'', ' num2str(useGUI) ')']);
end % pop_tagEEGStudy