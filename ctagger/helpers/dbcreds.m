% dbcreds
% GUI for creating database credentials 
%
% Usage:
%   >>  dbcreds()
%
% Description:
% dbcreds() brings up a gui that allows users to create a property file
%           that contains database credentials 
%
% Function documentation:
% Execute the following in the MATLAB command window to view the function
% documentation for dbcreds:
%
%    doc dbcreds
%
% See also: createdb, createdbc, deletedb, deletedbc
%
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
% $Log: dbcreds.m,v $
% $Revision: 1.00 15-Feb-2013 08:03:48 krobbins $
% $Initial version $
%

function configPath = dbcreds()
% Setup the variables used by the GUI
    configPath = '';
    theTitle = 'Create credential file for database access';
    inputFig = figure( ...
        'MenuBar', 'none', ...
        'Name', theTitle, ...
        'NextPlot', 'add', ...
        'NumberTitle','off', ...
        'Resize', 'on', ...
        'Tag', theTitle, ...
        'Toolbar', 'none', ...
        'Visible', 'off', ...
        'WindowStyle', 'modal');
    createLayout(inputFig);
    movegui(inputFig); % Make sure it is visible
    uiwait(inputFig);


    function buttons = createButtonPanel(parent)
        % Create the button panel on the bottum of GUI
        buttons = uiextras.Grid('Parent', parent, ...
            'Tag', 'SaveGrid', 'Spacing', 2, 'Padding', 1);
        %createControlButtons(buttons);
        uiextras.Empty('Parent', buttons);
        uicontrol('Parent', buttons, ...
            'Style', 'pushbutton', 'Tag', 'OkayButton', ...
            'String', 'Okay', 'Enable', 'on', 'Tooltip', ...
            'Save the current configuration in a file', ...
            'Callback', {@okayCallback, inputFig});
        uicontrol('Parent', buttons, ...
            'Style', 'pushbutton', 'Tag', 'CancelButton', ...
            'String', 'Cancel', 'Enable', 'on', 'Tooltip', ...
            'Cancel the directory tagging', ...
            'Callback', {@cancelCallback});
        set(buttons, 'RowSizes', 30, 'ColumnSizes', [-1 100 100]);
    end % createButtonPanel

    function createLayout(parent)
        % Create the layout for the GUI but do not display
        mainVBox = uiextras.VBox('Parent', parent, ...
            'Tag', 'MainVBox',  'Spacing', 5, 'Padding', 5);
        uiextras.Empty('Parent', mainVBox);
        createBrowsePanel(mainVBox);
        uiextras.Empty('Parent', mainVBox);
        createPropertiesPanel(mainVBox);
        uiextras.Empty('Parent', mainVBox);
        createButtonPanel(mainVBox);
        set(mainVBox, 'Sizes', [10, 30, 20 250,  -1,  40]);
        drawnow
    end % createLayout

    function createBrowsePanel(parent)
        fBox = uiextras.Grid('Parent', parent, ...
            'Tag', 'FileEntryGrid', 'Spacing', 5);
        uicontrol('Parent', fBox, ...
            'Style','text', 'String', 'Save props', ...
            'HorizontalAlignment', 'Right');
        savePropsCtrl = uicontrol('Parent', fBox, 'Style', 'edit', ...
            'BackgroundColor', 'w', 'HorizontalAlignment', 'Left', ...
            'Tag', 'SaveTags', 'String', '', ...
            'TooltipString', ...
            'Complete path for saving database credentials', ...
            'Callback', {@savePropsCtrlCallback});
        uicontrol('Parent', fBox, ...
            'string', 'Browse', 'style', 'pushbutton', ...
            'TooltipString', 'Press to find file name for saving credentials', ...
            'Callback', {@browseSavePropsCallback, savePropsCtrl, ...
            'Browse for base tags'});
        set(fBox, 'ColumnSizes', [80, -1, 100], 'RowSizes', 30);
    end

    function createPropertiesPanel(parent)
        % Create the button panel on the side of GUI
        panel = uiextras.Panel('Parent', parent, 'Title', ...
               'Other options', 'Padding', 10);
        bBox = uiextras.Grid('Parent', panel, ...
            'Tag', 'OptionsGrid', 'Spacing', 10);       
        uicontrol('Parent', bBox, ...
            'Style','text', 'String', 'Database name', ...
            'HorizontalAlignment', 'Right');
        uicontrol('Parent', bBox, ...
            'Style','text', 'String', 'Host name', ...
            'HorizontalAlignment', 'Right');
        uicontrol('Parent', bBox, ...
            'Style','text', 'String', 'Port number', ...
            'HorizontalAlignment', 'Right');
        uicontrol('Parent', bBox, ...
            'Style','text', 'String', 'User name', ...
            'HorizontalAlignment', 'Right');
        uicontrol('Parent', bBox, ...
            'Style','text', 'String', 'Password', ...
            'HorizontalAlignment', 'Right');

        uicontrol('Parent', bBox, 'Style', 'edit', ...
            'BackgroundColor', 'w', 'HorizontalAlignment', 'Left', ...
            'Tag', 'dbname', 'String', 'ctagger', ...
            'TooltipString', 'Database name for the remote server');
        uicontrol('Parent', bBox, 'Style', 'edit', ...
            'BackgroundColor', 'w', 'HorizontalAlignment', 'Left', ...
            'Tag', 'hostname', 'String', 'localhost', ...
            'TooltipString', 'URL of database server (or localhost for this machine)');
        uicontrol('Parent', bBox, 'Style', 'edit', ...
            'BackgroundColor', 'w', 'HorizontalAlignment', 'Left', ...
            'Tag', 'port', 'String', '5432', ...
            'TooltipString', 'Port number database server is monitoring');
       uicontrol('Parent', bBox, 'Style', 'edit', ...
            'BackgroundColor', 'w', 'HorizontalAlignment', 'Left', ...
            'Tag', 'username', 'String', 'postgres', ...
            'TooltipString', 'User login name');
        uicontrol('Parent', bBox, 'Style', 'edit', ...
            'BackgroundColor', 'w', 'HorizontalAlignment', 'Left', ...
            'Tag', 'password', 'String', 'admin', ...
            'TooltipString', 'Password for the specified user');
       set(bBox, 'ColumnSizes', [80, -1], 'RowSizes', [30, 30, 30, 30, 30]);
    end % createOptionsGroup

    function browseSavePropsCallback(src, eventdata, savePropsCtrl, myTitle) %#ok<INUSL>
        % Callback for browse button sets a directory for control
        startPath = get(savePropsCtrl, 'String');
        if isempty(startPath) || ~ischar(startPath) || ~isdir(startPath)
            startPath = pwd;
        end
        dName = uigetdir(startPath, myTitle);  % Get
        if ~isempty(dName) && ischar(dName) && isdir(dName)
            configPath = fullfile(dName, 'dbcreds.txt');
            set(savePropsCtrl, 'String', configPath);         
        end
    end % browseCallback

    function cancelCallback(src, eventdata)  %#ok<INUSD>
        % Callback for browse button sets a directory for control
        configPath = '';
        close(inputFig);
    end % cancelCallback

    function okayCallback(~, ~, infig, passObj) %#ok<INUSD>
        if isempty(configPath)
            warning('dbcreds:NoSaveFile', ...
                'Give a file name in order to create file or Press Cancel\n');
            return;
        end

        handles = guihandles(infig);
        dbname = get(handles.dbname, 'String');
        hostname = get(handles.hostname, 'String');
        port = str2double(get(handles.port, 'String'));
        username = get(handles.username, 'String');
        password = get(handles.password, 'String');
        %password = char(passObj.getText);
        edu.utsa.tagger.database.ManageDB.createCredentials(...
            configPath, dbname, hostname, port, username, password);
        close;
    end % closeButtonCallback


    function savePropsCtrlCallback(hObject, eventdata, saveTagsCtrl) %#ok<INUSD>
        % Callback for user directly editing directory control textbox
        configPath  = get(hObject, 'String');
    end % savePropsCtrlCallback

end % tagdir_input