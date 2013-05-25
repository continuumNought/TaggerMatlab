function newTags = tagevents(dTags, varargin)
    % Produce a new typeMap based on fields user wishes to tag
    parser = inputParser;
    parser.addRequired('DTags', @(x) (~isempty(x) && isa(x, 'typeMap')));
    parser.addParamValue('Synchronize', true, @islogical);
    parser.addParamValue('UseGUI', true, @islogical);

    parser.parse(dTags, varargin{:});
    p = parser.Results;
    dTags = p.DTags;
    xml = char(dTags.getXml()); 
    fields = dTags.getFields();
    fieldind = 1:length(fields);
    fieldtype = strcmpi(fields, 'type');
    newTags = typeMap(xml);
    if sum(fieldtype) >= 1  &&  tagNext('type') == 0% First tag the type field
        return;
    end
    restFields = fieldind(~fieldtype);
    for k = restFields
        if tagNext(fields{restFields(k)}) == 0
            return;
        end
    end
    
    function contFlg = tagNext(field)
        contFlg = 1;
        fieldMap = dTags.getMap(field);
        if isempty(fieldMap)
            return;
        end
        labels = fieldMap.getLabels();
        retValue = typedlg(field, labels);
        if strcmpi(retValue, 'Skip') || ...
            (strcmpi(retValue, 'Tag') && ~p.UseGui) %Add the tagmap with no change
            newTags.putTagMap(field, fieldMap(field));
            return;
        elseif strcmpi(retValue, 'Remove') % Don't use this one
            return;
        elseif strcmpi(retValue, 'Cancel') % Roll back and quit
            newTags = dTags.clone();
            contFlg = 0;
            return;
        elseif strcmpi(retValue, 'Quit') % Quit at this point
            contFlg = 0;
            return;
        end
        % Proceed with tagging
        eTitle = ['Tagging ' field ' values'];
        tEvents = char(fieldMap.getJsonEvents());
        if p.Synchronize
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
    end % tagNext
end % tagevents     