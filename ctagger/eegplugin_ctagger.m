% eegplugin_ctagger makes a ctagger plugin for EEGLAB 
%     
% Usage:
%   >> eegplugin_ctagger(fig, trystrs, catchstrs)
%
%% Description
% eegplugin_ctagger(fig, trystrs, catchstrs) makes a ctagger 
%    plugin for EEGLAB. The ctagger function displays a GUI for
%    performing hierarchical tagging of items. The plugin automatically
%    extracts the items and the current tagging structure from the
%    current EEG structure in EEGLAB.
% 
%    The fig, trystrs, and catchstrs arguments follow the
%    convention for plugins to EEGLAB. The fig argument holds the figure
%    number of the main EEGLAB GUI. The trystrs and catchstrs arguments
%    hold the try and catch strings for EEGLAB menu callbacks.
%
% Place the ctagger folder in the |plugins| subdirectory of EEGLAB.
% EEGLAB should detect the plugin on start up.  
%
% Notes:
%   See Contents.m for the contents of this plugin.
%
% See also: eeglab and pop_ctagger
%

%
% Copyright (C) 2012-2013 Thomas Rognon tcrognon@gmail.com and
% Kay Robbins, UTSA, kay.robbins@utsa.edu
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
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1.07  USA

% $Log: eegplugin_ctagger.m,v $
% Revision 1.0 03-Feb-2013 10:22:05  kay
% Initial revision
%

function vers = eegplugin_ctagger(fig, trystrs, catchstrs)
% 
    vers = 'ctagger1.0';
    if nargin < 3
        error('eegplugin_ctagger requires 3 arguments');
    end;

    % Find the path of the current directory
    tPath = which('eegplugin_ctagger.m');
    tPath = strrep(tPath, [filesep 'eegplugin_ctagger.m'], '');

    % Add ctagger folders to path if they aren't already there
    if ~exist('eegplugin_ctagger-subfoldertest.m', 'file')  % Dummy file to make sure not added
        addpath(genpath(tPath));  % Add all subfolders to path too
    end;

    % Add the jar files needed to run this
    jarPath = [tPath filesep 'jars' filesep];  % With jar
    warning off all;
    try
        javaaddpath([jarPath 'ctagger.jar']);
        javaaddpath([jarPath 'jackson.jar']);
        javaaddpath([jarPath 'postgresql-9.2-1002.jdbc4.jar']);
    catch mex  %#ok<NASGU>
    end
    warning on all;

    % Add to EEGLAB edit menu for current EEG dataset
    parentMenu = findobj(fig, 'Label', 'Edit');
    tagMenu = uimenu(parentMenu, 'Label', 'Tag events',  'Separator', 'on');
    
    % Add tagging of current EEG
    finalcmd = '[EEG LASTCOM] = pop_tagEEG(EEG);';
    ifeegcmd = 'if ~isempty(LASTCOM) && ~isempty(EEG)';
    savecmd = '[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET);';
    finalcmd =  [trystrs.no_check finalcmd ifeegcmd savecmd 'end;' catchstrs.add_to_hist];
    uimenu(tagMenu, 'Label', 'Tag current EEG', 'Callback', finalcmd);
    
    % Add tagging of directory of EEG
    finalcmd = '[~, ~, LASTCOM] = pop_tagEEGDir();';
    finalcmd =  [trystrs.no_check finalcmd catchstrs.add_to_hist];
    uimenu(tagMenu, 'Label', 'Tag EEG Directory', 'Callback', finalcmd, ...
        'Separator', 'on');

    
    