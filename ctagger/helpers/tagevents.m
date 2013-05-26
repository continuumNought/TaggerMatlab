% tagevents
% Allow user to selectively edit the tags.
%
% Usage:
%   >>  [tMap, fPaths] = tagdir(inDir)
%   >>  [tMap, fPaths] = tagdir(inDir, 'key1', 'value1', ...)
%
%% Description
% [eTags, fPaths] = tagdir(inDir)extracts a consolidated tagMap object 
% from the EEGLAB .set files in the directory tree inDir.
%
% First the events and tags from all EEGLAB .set files are extracted and 
% consolidated into a single typeMap object by merging all of the 
% existing tags. Then the ctagger GUI is displayed so that users can
% edit/modify the tags. The GUI is launched in synchronous mode, meaning 
% that it behaves like a modal dialog and must be closed before execution 
% continues. Finally the tags for each EEG file are updated.
%
% The final, consolidated and edited typeMap object is returned in tMap,
% and fPaths is a cell array containing the full path names of all of the
% matched files that were affected. If fPaths is empty, then tMap will also
% be empty.
%
%
% [eTags, fPaths] = tagdir(eData, 'key1', 'value1', ...) specifies 
% optional name/value parameter pairs:
%   'BaseTagsFile'   A file containing a typeMap object to be used
%                    for initial tag information. The default is an 
%                    tagMap object with the default HED XML and no tags.
%   'DoSubDirs'      If true the entire inDir directory tree is searched.
%                    If false, only the inDir directory is searched.  
%   'SelectFields'   If 'type', then only tags based on the
%                    event type field are considered. The 'select' option
%                    causes a series of selection GUIs to be displayed. 
%                    The 'none' option (default) causes no selection to be done.
%   'PreservePrefix' If false (default), tags of the same event type that
%                    share prefixes are combined and only the most specific
%                    is retained (e.g., /a/b/c and /a/b become just
%                    /a/b/c). If true, then all unique tags are retained.
%   'Synchronize'    If true (default), the ctagger GUI is run synchronously so
%                    no other MATLAB commands can be issued until this GUI
%                    is closed. A value of false is used when this function
%                    is being called as a menu item from another GUI.
%   'RewriteTags'    Rewrite tags back to the data files after tag map
%                    has been created.
%   'TagFileName'    Name containing the name of the file in which to
%                    save the consolidated typeMap object for future use.
%   'UpdateType'     Indicates how tags are merged with initial tags if the
%                    tagging information is to be rewritten to the EEG
%                    files. The options are: 'merge', 'replace', 
%                    'onlytags' (default), 'update' or 'none'.
%   'UseGui'         If true (default), the ctagger GUI is displayed after
%                    initialization.

function fMap = tagevents(fMap, varargin)
    % Check the input arguments for validity
    parser = inputParser;
    parser.addRequired('InMap', @(x) (~isempty(x) && isa(x, 'fieldMap')));
    parser.addParamValue('SelectFields',  'none', ...
          @(x) any(validatestring(lower(x), {'none', 'select', 'type'})));
    parser.addParamValue('Synchronize', true, @islogical);
    parser.addParamValue('UseGui', true, @islogical);
    parser.parse(inMap, varargin{:});
    selectFields = parser.Results.SelectFields;
    synchronize = parser.Results.Synchronize;
    useGui = parser.Results.UseGui;
    
    % Create fMap either by copying or by selecting each field
    if ~selectFields
        fMap = inMap.clone();
    else
        selectMap();   % Pick the fields to be tagged
    end
    
    function selectMap()
    xml = char(inMap.getXml()); 
    fields = inMap.getFields();
    fieldind = 1:length(fields);
    typefield = strcmpi(fields, 'type');
    if 
    fMap = fieldMap(xml);  % Create the return map
    if sum(typefield) >= 1  &&  tagNext('type') == 0% First tag the type field
        return;
    end
    restFields = fieldind(~typefield);
    for k = restFields
        if tagNext(fields{restFields(k)}) == 0
            return;
        end
    end
    end
    
    function contFlg = selectField(field)
        % Tag the values associated with field
        contFlg = 1;
        fieldMap = inMap.getMap(field);
        if isempty(fieldMap)
            labels = {' '};
        else
            labels = fieldMap.getLabels();
        end
        retValue = typedlg(field, labels);
        if strcmpi(retValue, 'Skip') || ...
            (strcmpi(retValue, 'Tag') && ~useGui) %Add the tagmap with no change
            fMap.putTagMap(field, fieldMap(field));
            return;
        elseif strcmpi(retValue, 'Remove') % Don't use this one
            return;
        elseif strcmpi(retValue, 'Cancel') % Roll back and quit
            fMap = inMap.clone();
            contFlg = 0;
            return;
        elseif strcmpi(retValue, 'Quit') % Quit at this point
            contFlg = 0;
            return;
        end
 
    end % tagNext

    function editTags(field)
       % Proceed with tagging
        eTitle = ['Tagging ' field ' values'];
        tEvents = char(fieldMap.getJsonEvents());
        if synchronize
            taggedList = edu.utsa.tagger.Controller.showDialog( ...
                  xml, tEvents, true, 0, eTitle, 3, false);
            tags = char(taggedList(1, :));
            events = char(taggedList(2, :));
        else
            ctrl = javaObjectEDT('edu.utsa.tagger.Controller', ...
                           xml, tEvents, true, 0, eTitle, 3, false);
            notified = ctrl.getNotified();
            while (~notified)
                pause(5);
                notified = ctrl.getNotified();
            end
            tags = char(ctrl.getHedString());
            events = char(ctrl.getEventString(true));  
        end                       %----TODO merge XML
        eTags.reset(strtrim(tags), tagMap.json2Events(strtrim(events)));
end % tagevents     