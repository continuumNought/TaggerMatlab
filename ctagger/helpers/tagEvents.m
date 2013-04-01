function eTags = tagEvents(eTags, varargin)
    % Tag this and produce a new tag structure
    parser = inputParser;
    parser.addRequired('ETags', @(x) (~isempty(x) && isa(x, 'eventTags')));
    parser.addParamValue('BaseTags', '', ...
        @(x)(isempty(x) || isa(x, 'eventTags')));
    parser.addParamValue('UpdateType', 'Merge', ...
          @(x) any(validatestring(x, ...
          {'Merge', 'Replace', 'TagsOnly', 'Update', 'NoUpdate'})));
    parser.addParamValue('UseGUI', true, @islogical);
    parser.parse(eTags, varargin{:});
    p = parser.Results;
    eTags = p.ETags;
    eTags.mergeEventTags(p.BaseTags, p.UpdateType)
    if p.UseGUI
        hed = char(eTags.getHedXML());              
        tEvents = char(eTags.getJsonEvents());          
        taggedList = char(edu.utsa.tagger.controller.Controller.showDialog( ...
            hed, tEvents, true));
        drawnow
        eTags.reset(char(strtrim(taggedList(1, :))), ...
                    eventTags.json2Events(char(strtrim(taggedList(2, :)))));
    end
end % tagEvents     