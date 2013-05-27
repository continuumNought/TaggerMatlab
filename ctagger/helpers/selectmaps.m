% selectmaps
% Allow user to selectively select the fields to be used
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
%   'SelectOption'   If 'type', then only tags based on the
%                    event type field are considered. The 'select' option
%                    (the default) causes a series of selection GUIs to be displayed.
%                    The 'none' option causes no selection to be done.
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

function [fMap, excluded] = selectmaps(fMap, varargin)

    % Check the input arguments for validity and initialize
    parser = inputParser;
    parser.addRequired('fMap', @(x) (~isempty(x) && isa(x, 'fieldMap')));
    parser.addParamValue('Fields', {}, @(x) (iscellstr(x)));
    parser.addParamValue('SelectOption', true, @islogical);
    parser.parse(fMap, varargin{:});

    % Figure out the fields to be used
    fields = fMap.getFields();
    sfields = parser.Results.Fields;
    if ~isempty(sfields)
       excluded = setdiff(fields, sfields);
       fields = intersect(fields, sfields);
       for k = 1:length(excluded)
           fMap.removeMap(excluded{k});
       end
    else
        excluded = {};
    end
 
    if isempty(fields) || ~parser.Results.SelectOption
        return;
    end
    
    excludeUser = {};
    % Tag the values associated with field
    for k = 1:length(fields)
        tMap = fMap.getMap(fields{k});
        if isempty(tMap)
            labels = {' '};
        else
            labels = tMap.getLabels();
        end
        retValue = tagdlg(fields{k}, labels);
        if strcmpi(retValue, 'Exclude')
            excludeUser = [excludeUser fields{k}]; %#ok<AGROW>
        elseif strcmpi(retValue, 'Cancel')
            excludeUser = {};
            break;
        end
    end
    
    if isempty(excludeUser)
        return;
    end
    
    % Remove the excluded fields
    for k = 1:length(excludeUser)
        fMap.removeMap(excludeUser{k});
    end
    excluded = union(excluded, excludeUser);
end