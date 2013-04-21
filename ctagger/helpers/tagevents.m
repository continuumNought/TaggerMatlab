function eTags = tagevents(eTags, varargin)
    % Tag this and produce a new tag structure
    parser = inputParser;
    parser.addRequired('ETags', @(x) (~isempty(x) && isa(x, 'eventTags')));
    parser.addParamValue('BaseTags', '', ...
        @(x)(isempty(x) || isa(x, 'eventTags')));
    parser.addParamValue('Synchronize', true, @islogical);
    parser.addParamValue('UpdateType', 'Merge', ...
          @(x) any(validatestring(lower(x), ...
          {'merge', 'replace', 'onlytags', 'update', 'none'})));
    parser.addParamValue('UseGUI', true, @islogical);

    parser.parse(eTags, varargin{:});
    p = parser.Results;
    eTags = p.ETags;
    eTags.mergeEventTags(p.BaseTags, p.UpdateType)
    if p.UseGUI
        hed = char(eTags.getHedXML());              
        tEvents = char(eTags.getJsonEvents());
        if p.Synchronize
            taggedList = edu.utsa.tagger.controller.Controller.showDialog( ...
                           hed, tEvents, true);
            tags = char(taggedList(1, :));
            events = char(taggedList(2, :));
        else
            ctrl = javaObjectEDT('edu.utsa.tagger.controller.Controller', ...
                           hed, tEvents, true);
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
end % tagEvents     