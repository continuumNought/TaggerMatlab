% pop_tagcsv
% Allows a user to tag a csv file
%
% Usage:
%   >>  [fMap, com] = pop_tagcsv()
%
% Outputs:
%    fMap   - a fieldMap object that contains the tag map information
%    com    - string containing call to tagstudy with all parameters
%
% See also:
%   eeglab, tageeg, tagdir, and eegplugin_ctagger
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


function [fMap, com] = pop_tagcsv()
% Create the tagger for a single EEG file
fMap = '';
com = '';

% Get the tagger input parameters
[baseMap, cancelled, dbCredsFile, delimiter, ...
    descriptionColumn, eventColumn, filename, preservePrefix, ...
    rewriteFile, saveMapFile, tagsColumn, useGUI] = ...
    tagcsv_input();
if cancelled
    return;
end

% Tag the EEG structure and return the command string
fMap = tagcsv(filename, ...
    'BaseMap', baseMap, ...
    'DbCreds', dbCredsFile, ...
    'Delimiter', delimiter, ...
    'DescriptionColumn', descriptionColumn, ...
    'EventColumns', eventColumn, ...
    'PreservePrefix', preservePrefix, ...
    'RewriteFile', rewriteFile, ...
    'SaveMapFile', saveMapFile, ...
    'TagsColumn', tagsColumn, ...
    'UseGUI', useGUI);
com = char(['tagcsv(''' filename ''', ' ...
    '''BaseMap'', ''' baseMap ''', ' ...
    '''DbCreds'', ''' dbCredsFile ''', ' ...
    '''Delimiter'', ''' delimiter ''', ' ...
    '''DescriptionColumn'', ' num2str(descriptionColumn) ', ' ...
    '''EventColumn'', ' num2str(eventColumn) ', ' ...
    '''PreservePrefix'', ' logical2str(preservePrefix) ', ' ...
    '''RewriteFile'', ''' rewriteFile ''', ' ...
    '''SaveMapFile'', ''' saveMapFile ''', ' ...
    '''TagsColumn'', ' num2str(tagsColumn) ', ' ...
    '''UseGui'', ' logical2str(useGUI) ')']);
end % pop_tagcsv

function s = logical2str(b)
if b
    s = 'true';
else
    s = 'false';
end
end % logical2str

