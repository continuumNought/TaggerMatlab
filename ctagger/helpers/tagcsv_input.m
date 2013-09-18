% tagcsv_input
% GUI for input needed to create inputs for tagcsv
%
function [filename, delimiter, baseMap, dbCredsFile, ...
    descriptionColumn, eventsColumn, preservePrefix, ...
    rewriteFile, saveMapFile,  selectOption, tagsColumn, useGUI, ...
    cancelled] = tagcsv_input()

% Setup the variables used by the GUI
baseMap = '';
cancelled = true;
delimiter = '';
dbCredsFile = '';
descriptionColumn = 0;
eventsColumn = 0;
preservePrefix = false;
saveMapFile = '';
selectOption = true;
filename = '';
rewriteFile = '';
tagsColumn = 0;
useGUI = true;
theTitle = 'Inputs for tagging csv file';
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
        createColumnGroup(mainHBox);
        uiextras.Empty('Parent', mainHBox);
        createRewriteGroup(mainHBox);
        uiextras.Empty('Parent', mainHBox);
        createOptionsGroup(mainHBox);
        uiextras.Empty('Parent', mainHBox);
        uiextras.Empty('Parent', mainVBox);
        createButtonPanel(mainVBox);
        uiextras.Empty('Parent', mainVBox);
        set(mainHBox, 'Sizes', [0, 150, 5, -1, 5, 175, 0]);
        set(mainVBox, 'Sizes', [0, 200, 165,  0,  30, 0]);
        drawnow
    end % createLayout

    function createBrowsePanel(parent)
        fBox = uiextras.Grid('Parent', parent, ...
            'Tag', 'FileEntryGrid', 'Spacing', 5);
        uicontrol('Parent', fBox, ...
            'Style','text', 'String', 'Event type file', ...
            'HorizontalAlignment', 'Right');
        uicontrol('Parent', fBox, ...
            'Style','text', 'String', 'Event data', ...
            'HorizontalAlignment', 'Right');
        uicontrol('Parent', fBox, ...
            'Style','text', 'String', 'Save csv', ...
            'HorizontalAlignment', 'Right');
        uicontrol('Parent', fBox, ...
            'Style','text', 'String', 'Base tags', ...
            'HorizontalAlignment', 'Right');
        uicontrol('Parent', fBox, ...
            'Style','text', 'String', 'Save tags', ...
            'HorizontalAlignment', 'Right');
        uicontrol('Parent', fBox, ...
            'Style','text', 'String', 'DB credentials', ...
            'HorizontalAlignment', 'Right');
        eventTypeCtrl = uicontrol('Parent', fBox, 'Style', 'edit', ...
            'BackgroundColor', 'w', 'HorizontalAlignment', 'Left', ...
            'Tag', 'CSVEdit', 'String', '', ...
            'TooltipString', ...
            'Event type file name', ...
            'Callback', {@eventTypeCtrlCallback});
        eventDataCtrl = uicontrol('Parent', fBox, 'Style', 'edit', ...
            'BackgroundColor', 'w', 'HorizontalAlignment', 'Left', ...
            'Tag', 'CSVEdit', 'String', '', ...
            'TooltipString', ...
            'Event data structure', ...
            'Callback', {@eventDataCtrlCallback});
        saveeventTypeCtrl = uicontrol('Parent', fBox, 'Style', 'edit', ...
            'BackgroundColor', 'w', 'HorizontalAlignment', 'Left', ...
            'Tag', 'RewriteEdit', 'String', '', ...
            'TooltipString', ...
            'Complete path for saving the csv file', ...
            'Callback', {@saveeventTypeCtrlCallback});
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
            'Callback', {@browseEventTypeCallback, eventTypeCtrl, ...
            'Browse for input directory'});
        uicontrol('Parent', fBox, ...
            'string', 'Browse', ...
            'style', 'pushbutton', 'TooltipString', ...
            'Press to bring up file chooser chooser', ...
            'Callback', {@browseEventDataCallback, eventDataCtrl, ...
            'Browse for input directory'});
        uicontrol('Parent', fBox, ...
            'string', 'Browse', ...
            'style', 'pushbutton', 'TooltipString', ...
            'Press to bring up file chooser chooser', ...
            'Callback', {@browseSaveCsvCallback, saveeventTypeCtrl, ...
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
        set(fBox, 'ColumnSizes', [80, -1, 100], 'RowSizes', [30, 30, 30, 30, 30, 30]);
    end % createBrowsePanel

    function createColumnGroup(parent)
        % Create the button panel on the side of GUI
        panel = uiextras.Panel('Parent', parent, 'Title', ...
            'Specify the csv columns:', 'Padding', 5);
        bBox = uiextras.Grid('Parent', panel, ...
            'Tag', 'UpdateGrid', 'Spacing', 5);
        uicontrol('Parent', bBox, ...
            'Style','text', 'String', 'Delimeter', ...
            'HorizontalAlignment', 'Right');
        uicontrol('Parent', bBox, ...
            'Style','text', 'String', 'Event type', ...
            'HorizontalAlignment', 'Right');
        uicontrol('Parent', bBox, ...
            'Style','text', 'String', 'Tags', ...
            'HorizontalAlignment', 'Right');
        uicontrol('Parent', bBox, ...
            'Style','text', 'String', 'Description', ...
            'HorizontalAlignment', 'Right');
        uicontrol('Parent', bBox, 'Style', 'edit', ...
            'BackgroundColor', 'w', 'HorizontalAlignment', 'Left', ...
            'Tag', 'EventEdit', 'String', '|', ...
            'TooltipString', ...
            'Event column(s)', ...
            'Callback', {@delimiterCtrlCallback});
        uicontrol('Parent', bBox, 'Style', 'edit', ...
            'BackgroundColor', 'w', 'HorizontalAlignment', 'Left', ...
            'Tag', 'EventEdit', 'String', '0', ...
            'TooltipString', ...
            'Event column(s)', ...
            'Callback', {@eventCtrlCallback});
        uicontrol('Parent', bBox, 'Style', 'edit', ...
            'BackgroundColor', 'w', 'HorizontalAlignment', 'Left', ...
            'Tag', 'TagEdit', 'String', '0', ...
            'TooltipString', ...
            'Tag column', ...
            'Callback', {@tagCtrlCallback});
        uicontrol('Parent', bBox, 'Style', 'edit', ...
            'BackgroundColor', 'w', 'HorizontalAlignment', 'Left', ...
            'Tag', 'DescriptionEdit', 'String', '0', ...
            'TooltipString', ...
            'Description column', ...
            'Callback', {@descriptionCtrlCallback});
        set(bBox, 'ColumnSizes', [60, -1, 10], 'RowSizes', [30, 30, 30, 30]);
    end % createColumnGroup

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
        set(bBox, 'ColumnSizes', 200, 'RowSizes', [30, 30, 30, 30, 30]);
    end % createOptionsGroup

    function createRewriteGroup(parent)
        % Create the button panel on the side of GUI
        panel = uiextras.Panel('Parent', parent, 'Title', ...
            'How to rewrite tags to dataset:', 'Padding', 5);
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

    function browseSaveCsvCallback(src, eventdata, saveeventTypeCtrl, myTitle) %#ok<INUSL>
        % Callback for browse button sets a directory for control
        startPath = get(saveeventTypeCtrl, 'String');
        if isempty(startPath) || ~ischar(startPath) || ~isdir(startPath)
            startPath = pwd;
        end
        dName = uigetdir(startPath, myTitle);  % Get
        if ~isempty(dName) && ischar(dName) && isdir(dName)
            rewriteFile = fullfile(dName, 'event.csv');
            set(saveeventTypeCtrl, 'String', rewriteFile);
        end
    end % browseSaveCsvCallback

    function browseEventTypeCallback(src, eventdata, eventTypeCtrl, myTitle) %#ok<INUSL>
        % Callback for browse button sets a directory for control
        [fName, fPath] = uigetfile({'*.csv', 'CSV Files'}, myTitle);
        fName = fullfile(fPath, fName);
        if ~isempty(fName) && ischar(fName) && exist(fName, 'file')
            set(eventTypeCtrl, 'String', fName);
            filename = fName;
        end
    end % browseEventTypeCallback

    function browseTagsCallback(src, eventdata, tagsCtrl, myTitle) %#ok<INUSL>
        % Callback for browse button sets a directory for control
        [tFile, tPath] = uigetfile({'*.mat', 'MATLAB Files (*.mat)'}, myTitle);
        baseMap = fullfile(tPath, tFile);
        set(tagsCtrl, 'String', baseMap);
    end % browseEventDataCallback

    function browseEventDataCallback(src, eventdata, eventDataCtrl, myTitle) %#ok<INUSL>
        % Callback for browse button sets a directory for control
        [tFile, tPath] = uigetfile({'*.fdt;*.mat;*.set', 'EEG data'}, myTitle);
        eventData = fullfile(tPath, tFile);
        set(eventDataCtrl, 'String', eventData);
    end % browseTagsCallback

    function cancelCallback(src, eventdata)  %#ok<INUSD>
        % Callback for browse button sets a directory for control
        baseMap = '';
        cancelled = true;
        delimiter = '';
        dbCredsFile = '';
        descriptionColumn = 0;
        eventsColumn = 0;
        preservePrefix = false;
        saveMapFile = '';
        selectOption = true;
        filename = '';
        rewriteFile = '';
        tagsColumn = 0;
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

    function saveTagsCtrlCallback(hObject, eventdata, saveTagsCtrl) %#ok<INUSD>
        % Callback for user directly editing directory control textbox
        saveMapFile = get(hObject, 'String');
    end % tagsCtrlCallback

    function saveeventTypeCtrlCallback(hObject, eventdata, saveeventTypeCtrl) %#ok<INUSD>
        % Callback for user directly editing directory control textbox
        rewriteFile = get(hObject, 'String');
    end % tagsCtrlCallback

    function selectCallback(src, eventdata) %#ok<INUSD>
        selectOption = get(src, 'Max') == get(src, 'Value');
    end % selectCallback

    function delimiterCtrlCallback(src, eventdata) %#ok<INUSD>
        delimiter = get(src, 'String');
    end  % delimiterCtrlCallback

    function eventCtrlCallback(src, eventdata) %#ok<INUSD>
        str = get(src,'String');
        pattern = '^[0-9]+(,[0-9]+)*$';
        if isempty(regexp(str, pattern, 'match'))
            set(src,'string','0');
            warndlg(['Input must be a number or a comma separated list' ...
                ' of numbers']);
        end
        eventsColumn = str2double(get(src, 'String'));
    end % tagCtrlCallback

    function tagCtrlCallback(src, eventdata) %#ok<INUSD>
        str = get(src,'String');
        pattern = '^[0-9]+$';
        if isempty(regexp(str, pattern, 'match'))
            set(src,'string','0');
            warndlg('Input must be a number');
        end
        tagsColumn = str2double(get(src, 'String'));
    end % tagCtrlCallback

    function descriptionCtrlCallback(src, eventdata) %#ok<INUSD>
        str = get(src,'String');
        pattern = '^[0-9]+$';
        if isempty(regexp(str, pattern, 'match'))
            set(src,'string','0');
            warndlg('Input must be a number');
        end
        descriptionColumn = str2double(get(src, 'String'));
    end % tagCtrlCallback

    function eventTypeCtrlCallback(hObject, eventdata) %#ok<INUSD>
        % Callback for user directly editing directory control textbox
        eventTypeFile = get(hObject, 'String');
        if exist(eventTypeFile, 'file')
            filename = eventTypeFile;
        else  % if user entered invalid directory reset back
            set(hObject, 'String', filename);
        end
    end % dirCtrlCallback

    function eventDataCtrlCallback(hObject, eventdata) %#ok<INUSD>
        % Callback for user directly editing directory control textbox
        eventData = get(hObject, 'String');
        if exist(eventData, 'file')
            filename = eventData;
        else  % if user entered invalid directory reset back
            set(hObject, 'String', filename);
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