% editmaps
% Allow user to selectively edit the tags using the ctagger GUI
%
% Usage:
%   >>  fMap = editmaps(fMap)
%   >>  fMap = editmaps(fMap, varargin)
%
%% Description
% fMap = editmaps(fMap) presents a CTAGGER tagging GUI for each of the 
% fields in fMap and allows users to tag, add items to the tag 
% hierarchy or add/edit events.
%
%
% fMap = editmaps(fMap, 'key1', 'value1', ...) specifies
% optional name/value parameter pairs:
%   'PreservePrefix' If false (default), tags of the same event type that
%                    share prefixes are combined and only the most specific
%                    is retained (e.g., /a/b/c and /a/b become just
%                    /a/b/c). If true, then all unique tags are retained.
%   'Synchronize'    If false (default), the ctagger GUI is run with
%                    synchronization done using the MATLAB pause. If
%                    true, synchronization is done within Java. This
%                    latter option is usually reserved when not calling
%                    the GUI from MATLAB.
%
function fMap = editmaps(fMap, varargin)

    % Check the input arguments for validity and initialize
    parser = inputParser;
    parser.addRequired('fMap', @(x) (~isempty(x) && isa(x, 'fieldMap')));
    parser.addParamValue('PreservePrefix', false, @islogical);
    parser.addParamValue('Synchronize', true, @islogical);
    parser.parse(fMap, varargin{:});
    syncThis = parser.Results.Synchronize;
    
    fields = fMap.getFields();
    for k = 1:length(fields)
        fprintf('Tagging %s\n', fields{k});
        editmap(fields{k});
    end

    function editmap(field)
        % Proceed with tagging
        eTitle = ['Tagging ' field ' values'];
        tMap = fMap.getMap(field);
        xml = fMap.getXml();
        if isempty(tMap)
            return;
        end
        tValues = strtrim(char(tMap.getJsonValues()));
        if syncThis
            taggedList = edu.utsa.tagger.Controller.showDialog( ...
                        xml, tValues, true, 0, char(eTitle), 3);
            xml = char(taggedList(1, :));
            tValues = strtrim(char(taggedList(2, :)));
        else
            javaMethodEDT('createController', 'edu.utsa.tagger.Controller', ...
                           xml, tValues, true, 0, eTitle, 3);
            notified = edu.utsa.tagger.Controller.get().getNotified();
            while (~notified)
                pause(5);
                notified = edu.utsa.tagger.Controller.get().getNotified();
            end
            taggedList = edu.utsa.tagger.Controller.getReturnString(true);
            if ~isempty(taggedList)
               xml = char(taggedList(1, :));
               tValues = strtrim(char(taggedList(2, :)));
            end
        end
        tValues = tagMap.json2Values(tValues);

        %----TODO merge XML
        %------TEMPORARY FIX
        
        if isfield(tValues, 'code')
            fprintf('----warning editmaps:CodeField --- Removing code field\n');
            tValues = rmfield(tValues, 'code');
        end
        if isfield(tValues, 'paths')
            fprintf('----warning editmaps:PathField --- Renaming path field to tags field\n');
            for j = 1:length(tValues) 
                tValues(j).tags = tValues(j).paths;
            end
            tValues = rmfield(tValues, 'paths');
        end
        fMap.mergeXml(strtrim(xml));
        fMap.removeMap(field);
        fMap.addValues(field, tValues);
    end % editmap
end % editmaps