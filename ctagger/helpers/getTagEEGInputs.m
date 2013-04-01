function [baseTagsFile, updateType, onlyType, ...
          saveTagsFile, useGUI, isCancelled] = getTagEEGInputs()
% GUI for input needed for cTagger.tagEEGDir

% Setup the variables used by the GUI
    baseTagsFile = '';
    isCancelled = true;
    onlyType = true;
    saveTagsFile = '';
    updateCtrl = '';
    updateType = 'TagsOnly';
    useGUI = true;
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


    function buttons = createButtonPanel(parent)
        % Create the button panel on the side of GUI
        buttons = uiextras.Grid('Parent', parent, ...
            'Tag', 'SaveGrid', 'Spacing', 2, 'Padding', 1);
        %createControlButtons(buttons);
        uiextras.Empty('Parent', buttons);
        uicontrol('Parent', buttons, ...
            'Style', 'pushbutton', 'Tag', 'CancelButton', ...
            'String', 'Cancel', 'Enable', 'on', 'Tooltip', ...
            'Cancel the directory tagging', ...
            'Callback', {@cancelCallback});
        uicontrol('Parent', buttons, ...
            'Style', 'pushbutton', 'Tag', 'OkayButton', ...
            'String', 'Okay', 'Enable', 'on', 'Tooltip', ...
            'Save the current configuration in a file', ...
            'Callback', {@okayCallback});
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
        createUpdateGroup(mainHBox);
        uiextras.Empty('Parent', mainHBox);
        createOptionsGroup(mainHBox);
        uiextras.Empty('Parent', mainHBox);
        uiextras.Empty('Parent', mainVBox);
        createButtonPanel(mainVBox);
        
        set(mainHBox, 'Sizes', [20, 150, 20, -1, 20]);
        set(mainVBox, 'Sizes', [10, 80, 200,  -1,  35]);
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
        tagsCtrl = uicontrol('Parent', fBox, 'style', 'edit', ...
            'BackgroundColor', 'w', ...
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
        set(fBox, 'ColumnSizes', [80, -1, 100], 'RowSizes', [30, 30]);
    end

    function createOptionsGroup(parent)
        % Create the button panel on the side of GUI
        panel = uiextras.Panel('Parent', parent, 'Title', ...
               'Other options', 'Padding', 5);
        bBox = uiextras.Grid('Parent', panel, ...
            'Tag', 'OptionsGrid', 'Spacing', 5);
        u1 = uicontrol('Parent', bBox, ...
            'Style', 'CheckBox', 'Tag', 'UseGUICB', ...
            'String', 'Use GUI to edit tags', 'Enable', 'on', 'Tooltip', ...
            'Use cTagger GUI to edit consolidated tags', ...
            'Callback', @useGUICallback);
        set(u1, 'Value', get(u1, 'Max'));
        u2 = uicontrol('Parent', bBox, ...
            'Style', 'CheckBox', 'Tag', 'OnlyTypeField', ...
            'String', 'Only tag type field of EEG events', 'Enable', 'on', 'Tooltip', ...
            'Only tag unique values of the type field of EEG', ...
            'Callback', @onlyTypeCallback);
        set(u2, 'Value', get(u2, 'Max'));
       set(bBox, 'ColumnSizes', 250, 'RowSizes', [30, 30, 30, 30, 30]);
    end % createButtonPanel

   function createUpdateGroup(parent)
        % Create the button panel on the side of GUI
        panel = uiextras.Panel('Parent', parent, 'Title', ...
               'EEG tag update options', 'Padding', 5);
        bBox = uiextras.Grid('Parent', panel, ...
            'Tag', 'UpdateGrid', 'Spacing', 5);
        updateCtrl = uicontrol('Parent', bBox, ...
            'Style', 'RadioButton', 'Tag', 'TagsOnlyUpdateButton', ...
            'String', 'TagsOnly', 'Enable', 'On', ...
            'Tooltip', 'Add new tags to for existing events.', ...
            'Callback', @updateCallback);
        set(updateCtrl, 'Value', get(updateCtrl, 'Max'));
        uicontrol('Parent', bBox, ...
            'Style', 'RadioButton', 'Tag', 'MergeUpdateButton', ...
            'String', 'Merge', 'Enable', 'on', 'Tooltip', ...
            ['Add event tags including those corresponding to events ' ...
            'that aren''t in this EEG.'], ...
            'Callback', @updateCallback);
        uicontrol('Parent', bBox, ...
            'Style', 'RadioButton', 'Tag', 'ReplaceUpdateButton', ...
            'String', 'Replace', 'Enable', 'on', 'Tooltip', ...
            ['If an event with that key is part of this object,' ...
             'completely replace that event tagging with the new version.'], ...
            'Callback', @updateCallback);
        uicontrol('Parent', bBox, ...
            'Style', 'RadioButton', 'Tag', 'UpdateUpdateButton', ...
            'String', 'Update', 'Enable', 'on', 'Tooltip', ...
            'Update descriptions as well as tags.', ...
            'Callback', @updateCallback);
        uicontrol('Parent', bBox, ...
            'Style', 'RadioButton', 'Tag', 'NoUpdateButton', ...
            'String', 'NoUpdate', 'Enable', 'on', 'Tooltip', ...
            'Don''t modify any EEG, just create consolidated tags', ...
            'Callback', @updateCallback);
       set(bBox, 'ColumnSizes', 200, 'RowSizes', [30, 30, 30, 30, 30]);
    end % createButtonPanel

    function browseSaveTagsCallback(src, eventdata, saveTagsCtrl, myTitle) %#ok<INUSL>
        % Callback for browse button sets a directory for control
        startPath = get(saveTagsCtrl, 'String');
        if isempty(startPath) || ~ischar(startPath) || ~isdir(startPath)
            startPath = pwd;
        end
        dName = uigetdir(startPath, myTitle);  % Get
        if ~isempty(dName) && ischar(dName) && isdir(dName)
            saveTagsFile = fullfile(dName, 'eTags.mat');
            set(saveTagsCtrl, 'String', saveTagsFile);         
        end
    end % browseCallback

    function browseTagsCallback(src, eventdata, tagsCtrl, myTitle) %#ok<INUSL>
        % Callback for browse button sets a directory for control
        [tFile, tPath] = uigetfile('*.mat', myTitle);
        tagsFile = fullfile(tPath, tFile);
        if isempty(eventTags.loadTagFile(tagsFile))
           warndlg([ tagsFile ' does not contain an eventTags object'], 'modal');
        else
            baseTagsFile = tagsFile;
            set(tagsCtrl, 'String', baseTagsFile);
        end
    end % browseTagsCallback

    function cancelCallback(src, eventdata)  %#ok<INUSD>
        % Callback for browse button sets a directory for control
        baseTagsFile = '';
        updateCtrl = '';
        updateType = 'TagsOnly';
        useGUI = true;
        fprintf('In Cancel\n');
        close(inputFig);
    end % browseTagsCallback

    function okayCallback(src, eventdata)  %#ok<INUSD>
        % Callback for closing GUI window
        isCancelled = false;
        fprintf('In Okay\n');
        close(inputFig);
    end % okayCallback

    function onlyTypeCallback(src, eventdata) %#ok<INUSD>
        onlyType = get(src, 'Max') == get(src, 'Value');
    end % useGUICallback

    function saveTagsCtrlCallback(hObject, eventdata, saveTagsCtrl) %#ok<INUSD>
        % Callback for user directly editing directory control textbox
        saveTagsFile = get(hObject, 'String');
%         if isempty(eventTags.loadTagFile(tagsFile))           
%            warndlg([ tagsFile ' does not contain an eventTags object'], 'modal');
%            set(hObject, 'String', baseTagsFile);
%         else
%            Tag = tagsFile;
%        end
    end % tagsCtrlCallback

    function tagsCtrlCallback(hObject, eventdata, tagsCtrl) %#ok<INUSD>
        % Callback for user directly editing directory control textbox
        tagsFile = get(hObject, 'String');
        if isempty(eventTags.loadTagFile(tagsFile))           
           warndlg([ tagsFile ' does not contain an eventTags object'], 'modal');
           set(hObject, 'String', baseTagsFile);
        else
            baseTagsFile = tagsFile;
        end
    end % tagsCtrlCallback

   function updateCallback(src, eventdata)    %#ok<INUSD>
       % Callback for the updateType button group
       if ~isempty(updateCtrl)
           set(updateCtrl, 'Value', get(updateCtrl, 'Min'));
       end
       updateCtrl = src;
       updateType = get(src, 'String');
    end % updateCallback

    function useGUICallback(src, eventdata) %#ok<INUSD>
        useGUI = get(src, 'Max') == get(src, 'Value');
    end % useGUICallback
           
end % getTagDirInputs