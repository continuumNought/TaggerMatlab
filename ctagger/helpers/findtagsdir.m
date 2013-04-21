function [eTags, fPaths] = getdirtags(inDir, varargin)
    % Assemble EEG files and extract a summary eventTags object
    p = inputParser;
    p.addRequired('InDir', @(x) (~isempty(x) && ischar(x)));
    p.addParamValue('DoSubDirs', true, @islogical);
    parser.addParamValue('Match', 'code', ...
           @(x) any(validatestring(lower(x), {'code', 'label', 'both'})));
    parser.addParamValue('OnlyType', true, @islogical);
    parser.addParamValue('PreservePrefix', false, @islogical);
    p.parse(inDir, varargin{:});        
    fPaths = getfilelist(p.Results.InDir, '.set', p.Results.DoSubDirs);
    eTags = eventTags('', '',  'Match', p.Match, 'PreservePrefix', ...
                      p.PreservePrefix);
    if isempty(fPaths)
        return;
    end
    for k = 1:length(fPaths) % Assemble the list
        EEG = pop_loadset(fPaths{k});
        eTagsNew = geteegtags(EEG);
        eTags.mergeEventTags(eTagsNew, 'Merge');
    end
end % getdirtags