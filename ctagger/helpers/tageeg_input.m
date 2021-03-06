% tageeg_input
% GUI for input needed to create inputs for tageeg 
%
% Usage:
%   >>  tageeg_input()
%
% Description:
% tageeg_input() brings up a GUI for input needed to create inputs for 
% tageeg 
%
% Function documentation:
% Execute the following in the MATLAB command window to view the function
% documentation for tageeg_input:
%
%    doc tageeg_input
% See also: tageeg, pop_tageeg
%
% Copyright (C) Kay Robbins and Thomas Rognon, UTSA, 2011-2013,
% krobbins@cs.utsa.edu
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
% $Log: tageeg_input.m,v $
% $Revision: 1.0 21-Apr-2013 09:25:25 krobbins $
% $Initial version $
%

function [baseMap,  dbCredsFile, preservePrefix, ...
    rewriteOption, saveMapFile, selectOption, useGUI, cancelled] = ...
    tageeg_input()

% Setup the variables used by the GUI
    baseMap = '';
    dbCredsFile = '';
    cancelled = true;
    preservePrefix = false;
    rewriteOption = 'Both';
    saveMapFile = '';
    selectOption = true;
    useGUI = true;
    rewriteCtrl = '';
    theTitle = 'Inputs for tagging an EEG structure';
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
    drawnow
    uiwait(inputFig);
    if ishandle(inputFig)
        close(inputFig);
    end


    function buttons = createButtonPanel(parent)
        % Create the button panel on the side of GUI
        buttons = uiextras.Grid('Parent', parent, ...
            'Tag', 'SaveGrid', 'Spacing', 2, 'Padding', 1);
        %createControlButtons(buttons);
        uiextras.Empty('Parent', buttons);
        uicontrol('Parent', buttons, ...
            'Style', 'pushbutton', 'Tag', 'OkayButton', ...
            'String', 'Okay', 'Enable', 'on', 'Tooltip', ...
            'Save the current configuration in a file', ...
            'Callback', {@okayCallback});
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
        mainHBox = uiextras.HBox('Parent', mainVBox, ...
            'Tag', 'MainHBox',  'Spacing', 5, 'Padding', 5);
        uiextras.Empty('Parent', mainHBox);
        createRewriteGroup(mainHBox);
        uiextras.Empty('Parent', mainHBox);
        createOptionsGroup(mainHBox);
        uiextras.Empty('Parent', mainHBox);
        uiextras.Empty('Parent', mainVBox);
        createButtonPanel(mainVBox);
        
        set(mainHBox, 'Sizes', [20, 200, 20, -1, 20]);
        set(mainVBox, 'Sizes', [10, 120, 200,  -1,  35]);
    end % createLayout

    function createBrowsePanel(parent)
        fBox = uiextras.Grid('Parent', parent, ...
            'Tag', 'FileEntryGrid', 'Spacing', 5);
        uicontrol('Parent', fBox, ...
            'Style','text', 'String', 'Base tags', ...
            'HorizontalAlignment', 'Right');
        uicontrol('Parent', fBox, ...
            'Style','text', 'String', 'Save tags', ...
            'HorizontalAlignment', 'Right');
        uicontrol('Parent', fBox, ...
            'Style','text', 'String', 'DB creds', ...
            'HorizontalAlignment', 'Right');
        tagsCtrl = uicontrol('Parent', fBox, 'style', 'edit', ...
            'BackgroundColor', 'w', 'HorizontalAlignment', 'Left', ...
            'Tag', 'BaseTagsEdit', 'String', '', ...
            'TooltipString', ...
            'Directory of .set files for visualization', ...
            'Callback', {@tagsCtrlCallback});
        saveTagsCtrl = uicontrol('Parent', fBox, 'Style', 'edit', ...
            'BackgroundColor', 'w', 'HorizontalAlignment', 'Left', ...
            'Tag', 'SaveTags', 'String', '', ...
            'TooltipString', ...
            'Complete path for saving the consolidated event tags', ...
            'Callback', {@saveTagsCtrlCallback});
        dbCredsCtrl = uicontrol('Parent', fBox, 'Style', 'edit', ...
            'BackgroundColor', 'w', 'HorizontalAlignment', 'Left', ...
            'Tag', 'DBCreds', 'String', '', ...
            'TooltipString', ...
            'Complete path for database credentials file', ...
            'Callback', {@dbCredsCtrlCallback});
        uicontrol('Parent', fBox, ...
            'string', 'Browse', 'style', 'pushbutton', ...
            'TooltipString', 'Press to choose BaseTags file', ...
            'Callback', {@browseTagsCallback, tagsCtrl, ...
            'Browse for base tags'});
        uicontrol('Parent', fBox, ...
            'string', 'Browse', 'style', 'pushbutton', ...
            'TooltipString', 'Press to find directory to save tags object', ...
            'Callback', {@browseSaveTagsCallback, saveTagsCtrl, ...
            'Browse for base tags'});
        uicontrol('Parent', fBox, ...
            'string', 'Browse', 'style', 'pushbutton', ...
            'TooltipString', 'Press to find your local database credentials file', ...
            'Callback', {@browseDbCredsCallback, dbCredsCtrl, ...
            'Browse for base tags'});
        set(fBox, 'ColumnSizes', [80, -1, 100], 'RowSizes', [30, 30, 30]);
    end % createBrowsePanel

    function createOptionsGroup(parent)
        % Create the button panel on the side of GUI
        panel = uiextras.Panel('Parent', parent, 'Title', ...
               'Other options', 'Padding', 5);
        bBox = uiextras.Grid('Parent', panel, ...
            'Tag', 'OptionsGrid', 'Spacing', 5);
        u1 = uicontrol('Parent', bBox, ...
            'Style', 'CheckBox', 'Tag', 'SelectOptionCB', ...
            'String', 'Use GUI to select fields to tag', 'Enable', 'on', 'Tooltip', ...
            'If checked, you will be presented with a GUI to select fields to tag', ...
            'Callback', @selectCallback);
        set(u1, 'Value', get(u1, 'Max'));
        u2 = uicontrol('Parent', bBox, ...
            'Style', 'CheckBox', 'Tag', 'UseGUICB', ...
            'String', 'Use GUI to edit tags', 'Enable', 'on', 'Tooltip', ...
            'Use cTagger GUI to edit consolidated tags', ...
            'Callback', @useGUICallback);
        set(u2, 'Value', get(u2, 'Max'));
        u3 = uicontrol('Parent', bBox, ...
            'Style', 'CheckBox', 'Tag', 'PreservePrefixfield', ...
            'String', 'Preserve tag prefixes', 'Enable', 'on', 'Tooltip', ...
            'Do not consolidate tags that share prefixes', ...
            'Callback', @preservePrefixCallback);
        set(u3, 'Value', get(u3, 'Min'));
        uiextras.Empty('Parent', bBox);
       set(bBox, 'ColumnSizes', 250, 'RowSizes', [30, 30, 30, 30, 30]);
    end % createOptionsGroup

   function createRewriteGroup(parent)
        % Create the button panel on the side of GUI
        panel = uiextras.Panel('Parent', parent, 'Title', ...
               'Options for rewrite', 'Padding', 5);
        bBox = uiextras.Grid('Parent', panel, ...
            'Tag', 'UpdateGrid', 'Spacing', 5);
        uicontrol('Parent', bBox, ...
            'Style', 'RadioButton', 'Tag', 'Summary', ...
            'String', 'Summary only', 'Enable', 'On', ...
            'Tooltip', 'Add tag summary to .etc.tags field of data', ...
            'Callback', @rewriteCallback);   
        uicontrol('Parent', bBox, ...
            'Style', 'RadioButton', 'Tag', 'Individual', ...
            'String', 'Individual events', 'Enable', 'on', 'Tooltip', ...
            'Add tags to individual events in .events.usertags', ...
            'Callback', @rewriteCallback);
        rewriteCtrl = uicontrol('Parent', bBox, ...
            'Style', 'RadioButton', 'Tag', 'Both', ...
            'String', 'Both', 'Enable', 'on', 'Tooltip', ...
            ['Rewrites tag summary to .etc.tags and tags to ' ...
             'individual events through .event.usertags'], ...
            'Callback', @rewriteCallback);
        set(rewriteCtrl, 'Value', get(rewriteCtrl, 'Max'));
        uicontrol('Parent', bBox, ...
            'Style', 'RadioButton', 'Tag', 'None', ...
            'String', 'None', 'Enable', 'on', 'Tooltip', ...
            'Don'' write any tags to the data or clear existing tags', ...
            'Callback', @rewriteCallback);
       set(bBox, 'ColumnSizes', 200, 'RowSizes', [30, 30, 30, 30]);
    end % createRewriteGroup

    function browseDbCredsCallback(src, eventdata, dbCredsCtrl, myTitle) %#ok<INUSL>
        % Callback for browse button sets a directory for control
        [tFile, tPath] = uigetfile({'*.*', 'All files (*.*)'}, myTitle);
        dbCredsFile = fullfile(tPath, tFile);
        set(dbCredsCtrl, 'String', fullfile(tPath, tFile));
    end % browseDbCredsCtrl Callback

    function browseSaveTagsCallback(src, eventdata, saveTagsCtrl, myTitle) %#ok<INUSL>
        % Callback for browse button sets a directory for control
        startPath = get(saveTagsCtrl, 'String');
        if isempty(startPath) || ~ischar(startPath) || ~isdir(startPath)
            startPath = pwd;
        end
        dName = uigetdir(startPath, myTitle);  % Get
        if ~isempty(dName) && ischar(dName) && isdir(dName)
            saveMapFile = fullfile(dName, 'fMap.mat');
            set(saveTagsCtrl, 'String', saveMapFile);         
        end
    end % browseSaveTagsCallback

    function browseTagsCallback(src, eventdata, tagsCtrl, myTitle) %#ok<INUSL>
        % Callback for browse button sets a directory for control
        [tFile, tPath] = uigetfile({'*.mat', 'MATLAB Files (*.mat)'}, myTitle);
        baseMap = fullfile(tPath, tFile);
        set(tagsCtrl, 'String', baseMap);
    end % browseTagsCallback

    function dbCredsCtrlCallback(hObject, eventdata, tagsCtrl) %#ok<INUSD>
        % Callback for user directly editing directory control textbox
        dbCredsFile = get(hObject, 'String');
        if ~exist(dbCredsFile, 'file')          
           warndlg([ dbCredsFile ' does not contain a typeMap object'], 'modal');
        end
    end % dbCredsCtrlCallback

    function cancelCallback(src, eventdata)  %#ok<INUSD>
        % Callback for browse button sets a directory for control
        baseMap = '';
        dbCredsFile = '';
        cancelled = true;
        preservePrefix = false;
        rewriteOption = 'Both';
        saveMapFile = '';
        selectOption = true;
        useGUI = true;
        rewriteCtrl = '';
        close(inputFig);
    end % browseTagsCallback

    function okayCallback(src, eventdata)  %#ok<INUSD>
        % Callback for closing GUI window
        cancelled = false;
        close(inputFig);
    end % okayCallback

    function saveTagsCtrlCallback(hObject, eventdata, saveTagsCtrl) %#ok<INUSD>
        % Callback for user directly editing directory control textbox
        saveMapFile = get(hObject, 'String');
    end % saveTagsCtrlCallback

    function preservePrefixCallback(src, eventdata) %#ok<INUSD>
        preservePrefix = get(src, 'Max') == get(src, 'Value');
    end % useGUICallback

   function rewriteCallback(src, eventdata)    %#ok<INUSD>
       % Callback for the updateType button group
       if ~isempty(rewriteCtrl)
           set(rewriteCtrl, 'Value', get(rewriteCtrl, 'Min'));
       end
       rewriteCtrl = src;
       rewriteOption = lower(get(src, 'Tag'));
    end % rewriteCallback

   function selectCallback(src, eventdata) %#ok<INUSD>
        selectOption = get(src, 'Max') == get(src, 'Value');
    end % selectCallback

    function tagsCtrlCallback(hObject, eventdata, tagsCtrl) %#ok<INUSD>
        % Callback for user directly editing directory control textbox
        tagsFile = get(hObject, 'String');
        if isempty(typeMap.loadTagFile(tagsFile))           
           warndlg([ tagsFile ' does not contain an typeMap object'], 'modal');
           set(hObject, 'String', baseMap);
        else
            baseMap = tagsFile;
        end
    end % tagsCtrlCallback

    function useGUICallback(src, eventdata) %#ok<INUSD>
        useGUI = get(src, 'Max') == get(src, 'Value');
    end % useGUICallback
           
end % tageeg_input