function dTags = tagevents(dTags, varargin)
    % Tag this and produce a new tag structure
    parser = inputParser;
    parser.addRequired('DTags', @(x) (~isempty(x) && isa(x, 'typeMap')));
    parser.addParamValue('BaseTags', '', ...
        @(x)(isempty(x) || isa(x, 'typeMap')));
    parser.addParamValue('Synchronize', true, @islogical);
    parser.addParamValue('UpdateType', 'Merge', ...
          @(x) any(validatestring(lower(x), ...
          {'merge', 'replace', 'onlytags', 'update', 'none'})));
    parser.addParamValue('UseGUI', true, @islogical);

    parser.parse(dTags, varargin{:});
    p = parser.Results;
    dTags = p.DTags;
    dTags.merge(p.BaseTags, p.UpdateType);
    if ~p.UseGUI
        return;
    end
    xml = char(dTags.getXml()); 
    tags = dTags.getEventTags();
    for k = 1:length(tags)
        eTags = tags{k};
        eTitle = [eTags.getField() ' field tagging'];
        tEvents = char(eTags.getJsonEvents());
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
        end
        eTags.reset(strtrim(tags), eventTags.json2Events(strtrim(events)));
    end
end % tagevents     