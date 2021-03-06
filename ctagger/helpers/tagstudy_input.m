% tagstudy_input
% GUI for input needed to create inputs for tagstudy
%
% Usage:
%   >>  tagstudy_input()
%
% Description:
% tagstudy_input() brings up a GUI for input needed to create inputs for 
% tagstudy
%
% Function documentation:
% Execute the following in the MATLAB command window to view the function
% documentation for tagstudy_input:
%
%    doc tagstudy_input
% See also: tagstudy, pop_tagstudy
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
% $Log: tagstudy_input.m,v $
% $Revision: 1.0 21-Apr-2013 09:25:25 krobbins $
% $Initial version $
%

function [studyFile, baseMap, dbCredsFile, preservePrefix, ...
    rewriteOption, saveAll, saveMapFile,  selectOption, useGUI, ...
    cancelled] = tagstudy_input()

% Setup the variables used by the GUI
baseMap = '';
cancelled = true;
dbCredsFile = '';
preservePrefix = false;
rewriteOption = 'Both';
rewriteCtrl = '';
saveAll = true;
saveMapFile = '';
selectOption = true;
studyFile = '';
useGUI = true;
theTitle = 'Inputs for tagging EEG study';
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
            'Cancel the study tagging', ...
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
        uiextras.Empty('Parent', mainVBox);
        set(mainHBox, 'Sizes', [20, 200, 10, -1, 10]);
        set(mainVBox, 'Sizes', [10, 150, 200,  -1,  40, 10]);
        drawnow
    end % createLayout

    function createBrowsePanel(parent)
        fBox = uiextras.Grid('Parent', parent, ...
            'Tag', 'FileEntryGrid', 'Spacing', 5);
        uicontrol('Parent', fBox, ...
            'Style','text', 'String', 'Study file', ...
            'HorizontalAlignment', 'Right');
        uicontrol('Parent', fBox, ...
            'Style','text', 'String', 'Base tags', ...
            'HorizontalAlignment', 'Right');
        uicontrol('Parent', fBox, ...
            'Style','text', 'String', 'Save tags', ...
            'HorizontalAlignment', 'Right');
        uicontrol('Parent', fBox, ...
            'Style','text', 'String', 'DB creds', ...
            'HorizontalAlignment', 'Right');
        studyCtrl = uicontrol('Parent', fBox, 'Style', 'edit', ...
            'BackgroundColor', 'w', 'HorizontalAlignment', 'Left', ...
            'Tag', 'StudyEdit', 'String', '', ...
            'TooltipString', ...
            'EEG study file name', ...
            'Callback', {@studyCtrlCallback});
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
            'string', 'Browse', ...
            'style', 'pushbutton', 'TooltipString', ...
            'Press to bring up file chooser chooser', ...
            'Callback', {@browseStudyCallback, studyCtrl, ...
            'Browse for input directory'});
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
        set(fBox, 'ColumnSizes', [80, -1, 100], 'RowSizes', [30, 30, 30, 30]);
    end % createBrowsePanel

    function createOptionsGroup(parent)
        % Create the button panel on the side of GUI
        panel = uiextras.Panel('Parent', parent, 'Title', ...
            'Other options', 'Padding', 5);
        bBox = uiextras.Grid('Parent', panel, ...
            'Tag', 'OptionsGrid', 'Spacing', 5);
        %{'Merge', 'Replace', 'TagsOnly', 'Update'})
        
        u1 = uicontrol('Parent', bBox, ...
            'Style', 'CheckBox', 'Tag', 'SelectOptionCB', ...
            'String', 'Use GUI to select fields to tag', 'Enable', 'on', 'Tooltip', ...
            'If checked, you will be presented with a GUI to select fields to tagG', ...
            'Callback', @selectCallback);
        set(u1, 'Value', get(u1, 'Max'));
        u2 = uicontrol('Parent', bBox, ...
            'Style', 'CheckBox', 'Tag', 'UseGUICB', ...
            'String', 'Use GUI to edit tags', 'Enable', 'on', 'Tooltip', ...
            'Use cTagger GUI to edit consolidated tags', ...
            'Callback', @useGUICallback);
        set(u2, 'Value', get(u2, 'Max'));
        u3 = uicontrol('Parent', bBox, ...
            'Style', 'CheckBox', 'Tag', 'PreservePrefixfieldCB', ...
            'String', 'Preserve tag prefixes', 'Enable', 'on', 'Tooltip', ...
            'Do not consolidate tags that share prefixes', ...
            'Callback', @preservePrefixCallback);
        set(u3, 'Value', get(u3, 'Min'));
        u4 = uicontrol('Parent', bBox, ...
            'Style', 'CheckBox', 'Tag', 'SaveAllCb', ...
            'String', 'Save to study datasets', 'Enable', 'on', 'Tooltip', ...
            'Save tags to study datasets in addition to study file', ...
            'Callback', @saveAllCallback);
        set(u4, 'Value', get(u4, 'Min'));
        set(bBox, 'ColumnSizes', 200, 'RowSizes', [30, 30, 30, 30, 30]);
    end % createOptionsGroup

    function createRewriteGroup(parent)
        % Create the button panel on the side of GUI
        panel = uiextras.Panel('Parent', parent, 'Title', ...
            'Options for rewrite', 'Padding', 5);
        bBox = uiextras.Grid('Parent', panel, ...
            'Tag', 'UpdateGrid', 'Spacing', 5);
        uicontrol('Parent', bBox, ...
            'Style', 'RadioButton', 'Tag', 'Summary', ...
            'String', 'Only summary', 'Enable', 'On', ...
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
    end % browseDbCredsCtrlCallback

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

    function browseStudyCallback(src, eventdata, studyCtrl, myTitle) %#ok<INUSL>
        % Callback for browse button sets a directory for control
        [fName, fPath] = uigetfile({'*.*', 'All files(*.*)'}, myTitle);
        fName = fullfile(fPath, fName);
        if ~isempty(fName) && ischar(fName) && exist(fName, 'file')
            set(studyCtrl, 'String', fName);
            studyFile = fName;
        end
    end % browseStudyCallback

    function browseTagsCallback(src, eventdata, tagsCtrl, myTitle) %#ok<INUSL>
        % Callback for browse button sets a directory for control
        [tFile, tPath] = uigetfile({'*.mat', 'MATLAB Files (*.mat)'}, myTitle);
        baseMap = fullfile(tPath, tFile);
        set(tagsCtrl, 'String', baseMap);
    end % browseTagsCallback

    function cancelCallback(src, eventdata)  %#ok<INUSD>
        % Callback for browse button sets a directory for control
        baseMap = '';
        cancelled = true;
        dbCredsFile = '';
        preservePrefix = false;
        rewriteCtrl = '';
        rewriteOption = 'Both';
        saveAll = true;
        saveMapFile = '';
        selectOption = true;
        studyFile = '';
        rewriteCtrl = '';
        useGUI = true;
        close(inputFig);
    end % cancelTagsCallback

    function dbCredsCtrlCallback(hObject, eventdata, tagsCtrl) %#ok<INUSD>
        % Callback for user directly editing directory control textbox
        dbCredsFile = get(hObject, 'String');
    end % dbCredsCtrlCallback

    function okayCallback(src, eventdata)  %#ok<INUSD>
        % Callback for closing GUI window
        cancelled = false;
        close(inputFig);
    end % okayCallback

    function preservePrefixCallback(src, eventdata) %#ok<INUSD>
        preservePrefix = get(src, 'Max') == get(src, 'Value');
    end % preservePrefixCallback

    function rewriteCallback(src, eventdata)    %#ok<INUSD>
        % Callback for the updateType button group
        if ~isempty(rewriteCtrl)
            set(rewriteCtrl, 'Value', get(rewriteCtrl, 'Min'));
        end
        rewriteCtrl = src;
        rewriteOption = lower(get(src, 'Tag'));
    end % rewriteCallback

    function saveAllCallback(src, eventdata) %#ok<INUSD>
        saveAll = get(src, 'Max') == get(src, 'Value');
    end % saveAllCallback

    function saveTagsCtrlCallback(hObject, eventdata, saveTagsCtrl) %#ok<INUSD>
        % Callback for user directly editing directory control textbox
        saveMapFile = get(hObject, 'String');
    end % tagsCtrlCallback

    function selectCallback(src, eventdata) %#ok<INUSD>
        selectOption = get(src, 'Max') == get(src, 'Value');
    end % selectCallback

    function studyCtrlCallback(hObject, eventdata) %#ok<INUSD>
        % Callback for user directly editing directory control textbox
        study = get(hObject, 'String');
        if exist(study, 'file')
            studyFile = study;
        else  % if user entered invalid directory reset back
            set(hObject, 'String', studyFile);
        end
    end % dirCtrlCallback

    function tagsCtrlCallback(hObject, eventdata, tagsCtrl) %#ok<INUSD>
        % Callback for user directly editing directory control textbox
        baseMap = get(hObject, 'String');
    end % tagsCtrlCallback

    function useGUICallback(src, eventdata) %#ok<INUSD>
        useGUI = get(src, 'Max') == get(src, 'Value');
    end % useGUICallback

end % tagstudy_input