function [EEG, eTags] = tagEEG(EEG, varargin)
    % Tag this EEG using eTagsBase as the structure
    parser = inputParser;
    parser.addRequired('EEG', @(x) (isempty(x) || isstruct(x)));
    parser.addParamValue('BaseTagsFile', '', ...
        @(x)(isempty(x) || (ischar(x))));
    parser.addParamValue('OnlyType', true, @islogical);
    parser.addParamValue('TagFileName', '', ...
         @(x)(isempty(x) || (ischar(x))));
    parser.addParamValue('UpdateType', 'TagsOnly', ...
          @(x) any(validatestring(x, ...
          {'Merge', 'Replace', 'TagsOnly', 'Update', 'NoUpdate'})));
    parser.addParamValue('UseGUI', true, @islogical);
    parser.parse(EEG, varargin{:});
    p = parser.Results;
    eTags = getEEGEventTags(p.EEG);
    baseTags = eventTags.loadTagFile(p.BaseTagsFile);
    eTags = tagEvents(eTags, 'BaseTags', baseTags, ...
                  'UpdateType', p.UpdateType, 'UseGUI', p.UseGUI);
    EEG.etc.eventTags = eTags.getJson();
    if ~isempty(p.TagFileName) && ...
        ~eventTags.saveTagFile(p.TagFileName, 'eTags')
        warning('tagEEG:invalidFile', ...
            ['Couldn''t save eventTags to ' p.TagFileName]);
    end
end % tagEEG